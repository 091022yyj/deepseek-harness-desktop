# DeepSeek Harness Desktop

[中文](README.zh.md) | English

DeepSeek Harness Desktop (`dsh-desktop`) packages the DeepSeek Harness web UI as a Linux desktop app: it starts a local service and opens it in a standalone app window, giving a near-native desktop experience.

## Features

- **One-click launch**: automatically starts the local service (default `http://127.0.0.1:3080`) and opens a Chromium/Chrome app window
- **Standalone window**: runs in `--app` mode with no tabs or address bar
- **Isolated profile**: uses a dedicated Chromium profile directory, separate from your daily browser
- **Works out of the box**: launch from the system app menu or the terminal after installation
- **Configurable**: customize port, browser, and external service address via environment variables

## Requirements

- Debian / Ubuntu or other dpkg-based Linux distributions (amd64)
- Node.js >= 22
- Google Chrome / Chromium or another Chromium-based browser (optional; falls back to `xdg-open`)

## Installation

Download the latest `deepseek-harness_*.deb` package from the [Releases](../../releases/latest) page, then run:

```sh
sudo dpkg -i deepseek-harness_0.1.0~rc.5_amd64.deb
```

After installation:

- **App menu**: find and click "DeepSeek Harness Desktop" in your system app menu
- **Terminal**: run `dsh-desktop`

## Usage

On launch, the desktop app starts a local service and opens the app window. The service defaults to `http://127.0.0.1:3080`; you can also open that address directly in a browser to use the web UI.

Supported environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `DSH_DESKTOP_PORT` | `3080` | Local service port |
| `DSH_DESKTOP_URL` | `http://127.0.0.1:3080` | Connect to an existing service instead of starting one locally |
| `DSH_DESKTOP_BROWSER` | auto-detected | Browser to use, e.g. `google-chrome`, `chromium` |

Log files:

- Service log: `$XDG_RUNTIME_DIR/dsh-desktop.log` (falls back to `/tmp/dsh-desktop.log`)
- Browser log: `$XDG_RUNTIME_DIR/dsh-desktop-browser.log` (falls back to `/tmp/dsh-desktop-browser.log`)

## Build from source

```sh
git clone https://github.com/091022yyj/deepseek-harness-desktop.git
cd deepseek-harness-desktop
pnpm install
pnpm run build:lib
pnpm run build:web
bash apps/desktop/build-deb.sh
```

Build artifacts are written to the `dist/` directory.

## License

[MIT](LICENSE)

Third-party dependencies and their licenses are disclosed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
