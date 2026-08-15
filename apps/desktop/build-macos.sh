#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_DIR"

VERSION="$(node -p "require('./apps/cli/package.json').version" 2>/dev/null || echo '0.1.0-rc.5')"
PKG_NAME="deepseek-harness"
OUT_DIR="$REPO_DIR/dist"
WORK_DIR="$(mktemp -d /tmp/dsh-mac.XXXXXX)"
DEPLOY_DIR="$WORK_DIR/deploy"
NODE_VERSION="v22.23.2"
NODE_DIST_CACHE="${NODE_DIST_CACHE:-$HOME/.cache/dsh-build/node-dist}"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

ensure_node() {
  local arch="$1"
  local dir="$NODE_DIST_CACHE/node-$NODE_VERSION-darwin-$arch"
  if [ ! -x "$dir/bin/node" ]; then
    mkdir -p "$NODE_DIST_CACHE"
    echo "==> 下载 Node.js $NODE_VERSION (darwin-$arch)" >&2
    curl -fsSL -o "$NODE_DIST_CACHE/node-mac.tar.xz" "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-darwin-$arch.tar.xz"
    tar xf "$NODE_DIST_CACHE/node-mac.tar.xz" -C "$NODE_DIST_CACHE"
    rm -f "$NODE_DIST_CACHE/node-mac.tar.xz"
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

prepare_root() {
  local ROOT="$1" ARCH="$2"
  mkdir -p "$ROOT/$PKG_NAME"
  cp -rL "$DEPLOY_DIR/." "$ROOT/$PKG_NAME/"
  local NODE_DIR
  NODE_DIR="$(ensure_node "$ARCH")"
  mkdir -p "$ROOT/$PKG_NAME/node/bin"
  cp "$NODE_DIR/bin/node" "$ROOT/$PKG_NAME/node/bin/node"
  chmod 755 "$ROOT/$PKG_NAME/node/bin/node"
  cp apps/desktop/dsh-desktop.command apps/desktop/dsh.sh "$ROOT/$PKG_NAME/"
  chmod +x "$ROOT/$PKG_NAME/dsh-desktop.command"
  mv "$ROOT/$PKG_NAME/dsh.sh" "$ROOT/$PKG_NAME/dsh"
  chmod +x "$ROOT/$PKG_NAME/dsh"
}

echo "==> 打包 macOS 便携版（x64）"
MAC_X64="$WORK_DIR/mac-x64"
prepare_root "$MAC_X64" x64
( cd "$MAC_X64" && zip -rq "$OUT_DIR/${PKG_NAME}_${VERSION}_macos-x64.zip" "$PKG_NAME" )

echo "==> 打包 macOS 便携版（arm64）"
MAC_ARM="$WORK_DIR/mac-arm64"
prepare_root "$MAC_ARM" arm64
( cd "$MAC_ARM" && zip -rq "$OUT_DIR/${PKG_NAME}_${VERSION}_macos-arm64.zip" "$PKG_NAME" )

echo "==> 完成"
ls -lh "$OUT_DIR"/*macos*.zip
