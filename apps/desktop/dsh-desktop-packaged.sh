#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${DSH_DESKTOP_INSTALL_DIR:-/opt/deepseek-harness}"
APP_NAME="DeepSeek Harness"
PORT="${DSH_DESKTOP_PORT:-3080}"
DEFAULT_URL="http://127.0.0.1:${PORT}"
LOG_FILE="${XDG_RUNTIME_DIR:-/tmp}/dsh-desktop.log"
BROWSER_LOG_FILE="${XDG_RUNTIME_DIR:-/tmp}/dsh-desktop-browser.log"
PROFILE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dsh-desktop/chromium-profile"
START_URL="${DSH_DESKTOP_URL:-$DEFAULT_URL}"

info()  { printf '\033[1;36m[dsh-desktop]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[dsh-desktop]\033[0m %s\n' "$*" >&2; }
notify_error() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "$APP_NAME" -i dialog-error "$APP_NAME" "$1" >/dev/null 2>&1 || true
  fi
}
fail()  {
  printf '\033[1;31m[dsh-desktop]\033[0m %s\n' "$*" >&2
  notify_error "$*"
  exit 1
}

fetch_url() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsS --max-time 2 "$1" 2>/dev/null
  elif command -v node >/dev/null 2>&1; then
    node -e 'fetch(process.argv[1],{signal:AbortSignal.timeout(2000)}).then(r=>{if(!r.ok)process.exit(1);return r.text()}).then(t=>process.stdout.write(t)).catch(()=>process.exit(1))' "$1"
  else
    return 1
  fi
}

is_serving_dsh() {
  fetch_url "$1" 2>/dev/null | grep -q '__DSH_BOOT__'
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
  info "使用外部服务地址：$START_URL"
else
  if ! is_serving_dsh "$START_URL"; then
    if fetch_url "$START_URL" >/dev/null 2>&1; then
      fail "端口 ${PORT} 已被其他程序占用。请停止该程序，或设置 DSH_DESKTOP_URL 指向已有的 DeepSeek Harness 服务。"
    fi

    if [ ! -x "$INSTALL_DIR/bin/dsh" ]; then
      fail "未找到 DeepSeek Harness 程序：$INSTALL_DIR/bin/dsh"
    fi

    info "启动 DeepSeek Harness 本地服务..."
    mkdir -p "$(dirname "$LOG_FILE")"
    : > "$LOG_FILE"
    setsid -f "$INSTALL_DIR/bin/dsh" web --port "$PORT" >>"$LOG_FILE" 2>&1 < /dev/null
    sleep 1
  fi

  info "等待服务就绪..."
  if ! wait_for_dsh "$START_URL"; then
    warn "服务未在预期时间内就绪，日志如下（最后 40 行）："
    tail -n 40 "$LOG_FILE" >&2 || true
    fail "本地服务启动失败，请查看日志：$LOG_FILE"
  fi
  info "服务已就绪：$START_URL"
fi

BROWSER="${DSH_DESKTOP_BROWSER:-}"
if [ -z "$BROWSER" ]; then
  for candidate in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser; do
    if command -v "$candidate" >/dev/null 2>&1; then
      BROWSER="$candidate"
      break
    fi
  done
fi

if [ -z "$BROWSER" ]; then
  warn "未找到 Chromium/Chrome，改用 xdg-open 打开。"
  xdg-open "$START_URL" >/dev/null 2>&1 < /dev/null &
  exit 0
fi

info "打开 $APP_NAME 桌面窗口..."
mkdir -p "$PROFILE_DIR"
nohup "$BROWSER" \
  --app="$START_URL" \
  --class=DeepSeekHarness \
  --user-data-dir="$PROFILE_DIR" \
  --no-first-run \
  --no-default-browser-check \
  --no-service-autorun \
  --ozone-platform=x11 \
  >>"$BROWSER_LOG_FILE" 2>&1 < /dev/null &
