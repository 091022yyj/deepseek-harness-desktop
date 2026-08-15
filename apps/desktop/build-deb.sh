#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_DIR"

ARCH="${DSH_DEB_ARCH:-$(dpkg --print-architecture)}"
VERSION="$(node -p "require('./apps/cli/package.json').version" 2>/dev/null || echo '0.1.0-rc.5')"
DEB_VERSION="${VERSION//-rc./~rc.}"
PKG_NAME="deepseek-harness"
OUT_DIR="$REPO_DIR/dist"
WORK_DIR="$(mktemp -d /tmp/dsh-deb.XXXXXX)"
DEPLOY_DIR="$WORK_DIR/deploy"
ROOT_DIR="$WORK_DIR/root"
INSTALL_DIR="/opt/deepseek-harness"
NODE_VERSION="v22.23.2"
NODE_DIST_CACHE="${NODE_DIST_CACHE:-$HOME/.cache/dsh-build/node-dist}"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

ensure_node() {
  local dir="$NODE_DIST_CACHE/node-$NODE_VERSION-linux-x64"
  if [ ! -x "$dir/bin/node" ]; then
    mkdir -p "$NODE_DIST_CACHE"
    echo "==> 下载 Node.js $NODE_VERSION (linux-x64)" >&2
    curl -fsSL -o "$NODE_DIST_CACHE/node.tar.xz" "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz"
    tar xf "$NODE_DIST_CACHE/node.tar.xz" -C "$NODE_DIST_CACHE"
    rm -f "$NODE_DIST_CACHE/node.tar.xz"
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

echo "==> 部署 CLI 及其运行时依赖（pnpm deploy）"
rm -rf "$DEPLOY_DIR"
pnpm --config.inject-workspace-packages=true --config.strict-dep-builds=false --filter @deepseek-ai/dsh deploy --prod "$DEPLOY_DIR"

echo "==> 组装包目录"
mkdir -p "$ROOT_DIR$INSTALL_DIR" "$ROOT_DIR/DEBIAN" "$OUT_DIR"

cp -a "$DEPLOY_DIR/." "$ROOT_DIR$INSTALL_DIR/"

mkdir -p "$ROOT_DIR$INSTALL_DIR/bin"
cat > "$ROOT_DIR$INSTALL_DIR/bin/dsh" <<'EOF'
#!/bin/sh
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
if [ -x "$SCRIPT_DIR/../node/bin/node" ]; then
  NODE_BIN="$SCRIPT_DIR/../node/bin/node"
else
  NODE_BIN="$(command -v node 2>/dev/null || true)"
  if [ -z "$NODE_BIN" ]; then
    echo "未找到 Node.js，请安装 Node.js 22+ 或重新安装本程序。" >&2
    exit 1
  fi
fi
exec "$NODE_BIN" "$SCRIPT_DIR/../lib/bin.js" "$@"
EOF
chmod 755 "$ROOT_DIR$INSTALL_DIR/bin/dsh"

NODE_DIR="$(ensure_node)"
mkdir -p "$ROOT_DIR$INSTALL_DIR/node/bin"
cp "$NODE_DIR/bin/node" "$ROOT_DIR$INSTALL_DIR/node/bin/node"
chmod 755 "$ROOT_DIR$INSTALL_DIR/node/bin/node"

cp apps/desktop/dsh-desktop-packaged.sh "$ROOT_DIR$INSTALL_DIR/bin/dsh-desktop"
chmod 755 "$ROOT_DIR$INSTALL_DIR/bin/dsh-desktop"
mkdir -p "$ROOT_DIR$INSTALL_DIR/assets"
cp apps/desktop/assets/icon.png "$ROOT_DIR$INSTALL_DIR/assets/icon.png"

mkdir -p "$ROOT_DIR/usr/share/applications" "$ROOT_DIR/usr/share/icons/hicolor/256x256/apps"
cat > "$ROOT_DIR/usr/share/applications/deepseek-harness.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=DeepSeek Harness
Name[zh_CN]=DeepSeek Harness 桌面端
Comment=DeepSeek Harness desktop client
Comment[zh_CN]=DeepSeek Harness 桌面客户端
Exec=$INSTALL_DIR/bin/dsh-desktop
Icon=deepseek-harness
Terminal=false
StartupWMClass=DeepSeekHarness
Categories=Development;
StartupNotify=true
Keywords=deepseek;harness;dsh;agent;ai;
EOF
cp apps/desktop/assets/icon.png "$ROOT_DIR/usr/share/icons/hicolor/256x256/apps/deepseek-harness.png"

INSTALLED_SIZE="$(du -sk "$ROOT_DIR$INSTALL_DIR" | cut -f1)"

cat > "$ROOT_DIR/DEBIAN/control" <<EOF
Package: $PKG_NAME
Version: $DEB_VERSION
Section: devel
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Maintainer: DeepSeek Harness Desktop <dsh-desktop@localhost>
Recommends: xdg-utils, curl
Suggests: chromium-browser | google-chrome-stable
Description: DeepSeek Harness desktop client (Web UI in a Chromium app window)
 DeepSeek Harness (dsh) is an open-source agent harness.
 This package bundles its own Node.js runtime and installs the dsh CLI and a
 desktop launcher that serves the Web UI on 127.0.0.1 and opens it in a
 Chromium/Chrome --app window.
EOF

DEB_FILE="$OUT_DIR/${PKG_NAME}_${DEB_VERSION}_${ARCH}.deb"
echo "==> 打包 $DEB_FILE"
fakeroot dpkg-deb --root-owner-group --build "$ROOT_DIR" "$DEB_FILE"

echo "✅ 完成：$DEB_FILE"
du -h "$DEB_FILE"
