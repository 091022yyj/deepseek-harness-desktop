#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR"
APP_NAME="DeepSeek Harness"
PORT="${DSH_DESKTOP_PORT:-3080}"
DEFAULT_URL="http://127.0.0.1:${PORT}"
LOG_FILE="${TMPDIR:-/tmp}dsh-desktop.log"
BROWSER_LOG_FILE="${TMPDIR:-/tmp}dsh-desktop-browser.log"
PROFILE_DIR="${HOME}/Library/Application Support/dsh-desktop/chromium-profile"
START_URL="${DSH_DESKTOP_URL:-$DEFAULT_URL}"

info() { printf '\033[1;36m[dsh-desktop]\033[0m %s\n' "$*"; }
fail() {
  printf '\033[1;31m[dsh-desktop]\033[0m %s\n' "$*" >&2
  exit 1
}

NODE_BIN=""
find_node() {
  if [ -x "$INSTALL_DIR/node/bin/node" ]; then
    NODE_BIN="$INSTALL_DIR/node/bin/node"
  elif command -v node >/dev/null 2>&1; then
    NODE_BIN="$(command -v node)"
  else
    return 1
  fi
}

is_serving_dsh() {
  curl -fsS --max-time 2 "$1" 2>/dev/null | grep -q '__DSH_BOOT__'
}

wait_for_dsh() {
  local url="$1" tries=120
  for _ in $(seq 1 "$tries"); do
    if is_serving_dsh "$url"; then
      return 0
    fi
    sleep 0.25
  done
  return 1
}

if [ -n "${DSH_DESKTOP_URL:-}" ]; then
  info "Using external service: $START_URL"
else
  if is_serving_dsh "$START_URL"; then
    :
  elif curl -fsS --max-time 2 "$START_URL" >/dev/null 2>&1; then
    fail "Port ${PORT} is used by another program. Stop it, or set DSH_DESKTOP_URL to an existing DeepSeek Harness service."
  else
    if [ ! -f "$INSTALL_DIR/lib/bin.js" ]; then
      fail "DeepSeek Harness program not found: $INSTALL_DIR/lib/bin.js"
    fi
    if ! find_node; then
      fail "Node.js not found. Install Node.js 22+ or reinstall this program."
    fi
    info "Starting DeepSeek Harness local service..."
    mkdir -p "$(dirname "$LOG_FILE")"
    : > "$LOG_FILE"
    nohup "$NODE_BIN" "$INSTALL_DIR/lib/bin.js" web --port "$PORT" >>"$LOG_FILE" 2>&1 </dev/null &
    sleep 1
  fi

  info "Waiting for the service..."
  if ! wait_for_dsh "$START_URL"; then
    tail -n 40 "$LOG_FILE" >&2 || true
    fail "Local service failed to start, see log: $LOG_FILE"
  fi
  info "Service ready: $START_URL"
fi

BROWSER="${DSH_DESKTOP_BROWSER:-}"
if [ -z "$BROWSER" ]; then
  for candidate in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    if [ -x "$candidate" ]; then
      BROWSER="$candidate"
      break
    fi
  done
fi

if [ -z "$BROWSER" ]; then
  info "Chromium/Chrome not found, opening in the default browser."
  open "$START_URL" >/dev/null 2>&1 </dev/null &
  exit 0
fi

info "Opening $APP_NAME app window..."
mkdir -p "$PROFILE_DIR"
nohup "$BROWSER" \
  --app="$START_URL" \
  --user-data-dir="$PROFILE_DIR" \
  --no-first-run \
  --no-default-browser-check \
  >>"$BROWSER_LOG_FILE" 2>&1 </dev/null &
