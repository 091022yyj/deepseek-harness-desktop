#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_DIR"

VERSION="$(node -p "require('./apps/cli/package.json').version" 2>/dev/null || echo '0.1.0-rc.5')"
PKG_NAME="deepseek-harness"
OUT_DIR="$REPO_DIR/dist"
WORK_DIR="$(mktemp -d /tmp/dsh-win.XXXXXX)"
DEPLOY_DIR="$WORK_DIR/deploy"
NSIS_DIR="$WORK_DIR/nsis"
NODE_VERSION="v22.23.2"
NODE_DIST_CACHE="${NODE_DIST_CACHE:-$HOME/.cache/dsh-build/node-dist}"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

ensure_node() {
  local dir="$NODE_DIST_CACHE/node-$NODE_VERSION-win-x64"
  if [ ! -f "$dir/node.exe" ]; then
    mkdir -p "$NODE_DIST_CACHE"
    echo "==> 下载 Node.js $NODE_VERSION (win-x64)" >&2
    curl -fsSL -o "$NODE_DIST_CACHE/node-win.zip" "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-win-x64.zip"
    unzip -q -o "$NODE_DIST_CACHE/node-win.zip" -d "$NODE_DIST_CACHE"
    rm -f "$NODE_DIST_CACHE/node-win.zip"
  fi
  echo "$dir"
}

if [ "${1:-}" != "--skip-build" ]; then
  echo "==> 构建 lib 与 web"
  pnpm run build:lib
  pnpm run build:web
else
  [ -f apps/cli/lib/bin.js ] || { echo "apps/cli/lib/bin.js 不存在，请先构建"; exit 1; }
  [ -f apps/web/dist/index.html ] || { echo "apps/web/dist 不存在，请先构建"; exit 1; }
fi

echo "==> 部署运行时依赖（pnpm deploy）"
rm -rf "$DEPLOY_DIR"
pnpm --config.inject-workspace-packages=true --config.strict-dep-builds=false --filter @deepseek-ai/dsh deploy --prod "$DEPLOY_DIR"

echo "==> 组装 NSIS 打包目录"
mkdir -p "$NSIS_DIR"
cp -rL "$DEPLOY_DIR" "$NSIS_DIR/deploy"
NODE_DIR="$(ensure_node)"
mkdir -p "$NSIS_DIR/node"
cp "$NODE_DIR/node.exe" "$NSIS_DIR/node/node.exe"
mkdir -p "$NSIS_DIR/assets"
cp apps/desktop/assets/icon.ico "$NSIS_DIR/assets/icon.ico"
cp apps/desktop/dsh-desktop.nsi "$NSIS_DIR/"
cp apps/desktop/dsh-desktop.ps1 apps/desktop/dsh.cmd apps/desktop/run-service.cmd "$NSIS_DIR/"

echo "==> 生成 Windows 安装器"
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/${PKG_NAME}_${VERSION}_windows-setup.exe"
( cd "$NSIS_DIR" && makensis "-DVERSION=$VERSION" "-DDIST_OUT=$OUT_FILE" dsh-desktop.nsi )

echo "==> 完成"
ls -lh "$OUT_FILE"
