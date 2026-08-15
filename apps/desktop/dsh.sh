#!/bin/sh
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
if [ -x "$SCRIPT_DIR/node/bin/node" ]; then
  NODE_BIN="$SCRIPT_DIR/node/bin/node"
else
  NODE_BIN="$(command -v node 2>/dev/null || true)"
  if [ -z "$NODE_BIN" ]; then
    echo "未找到 Node.js，请安装 Node.js 22+ 或重新安装本程序。" >&2
    exit 1
  fi
fi
exec "$NODE_BIN" "$SCRIPT_DIR/lib/bin.js" "$@"
