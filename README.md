# DeepSeek Harness Desktop

[中文](README.zh.md) | English

DeepSeek Harness Desktop (`dsh-desktop`) is a Linux desktop app that packages the full DeepSeek Harness (`dsh`) agent framework and its web UI. On launch it starts a local service and opens it in a standalone app window for a near-native desktop experience.

DeepSeek Harness is an open-source agent harness with an **everything-is-a-plugin** architecture: configure a model and a workspace in the web UI, and let the agent read and edit project files, run commands, delegate subtasks, and maintain a plan.

## Key features

### Desktop app

- **One-click launch**: automatically starts the local service (default `http://127.0.0.1:3080`) and opens a Chromium/Chrome app window
- **Standalone window**: runs in `--app` mode with no tabs or address bar
- **Isolated profile**: uses a dedicated Chromium profile directory, separate from your daily browser
- **Works out of the box**: launch from the system app menu or the terminal after installation
- **Configurable**: customize port, browser, and external service address via environment variables

### Software features

- **Web UI**: model configuration, workspace management, conversational agent sessions, with approval prompts for sensitive operations
- **Multiple model providers**: DeepSeek API, other providers, and custom OpenAI-compatible endpoints
- **Multiple run modes**: `dsh web` (web UI) and `dsh --profile headless "task"` (one-shot headless execution)
- **Plugin system**: everything is a plugin; manage profile plugins with `dsh plugin`, and tag plugin repositories with [`dsh-plugin`](https://github.com/topics/dsh-plugin) for discoverability
- **Python SDK and agent examples**: a Python SDK plus ACP / headless / jsonrpc agent examples in the repository

## Requirements

- Debian / Ubuntu or other dpkg-based Linux distributions (amd64)
- Node.js >= 22
- Google Chrome / Chromium or another Chromium-based browser (optional; falls back to `xdg-open`)

## Installation

### Package (recommended)

Download the latest `deepseek-harness_*.deb` package from the [Releases](../../releases/latest) page, then run:

```sh
sudo dpkg -i deepseek-harness_0.1.0~rc.5_amd64.deb
```

After installation:

- **App menu**: find and click "DeepSeek Harness Desktop" in your system app menu
- **Terminal**: run `dsh-desktop`

### Run via npm

Install `Node.js`, then run:

```sh
npx @deepseek-ai/dsh web
```

This starts the Web UI, served at `http://127.0.0.1:3080` by default.

## Usage

### Launch the desktop app

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

### Web UI quick start

1. **Configure a model**: open **Settings → Models**, enter an API key, and save it — it takes effect without a restart
2. **Choose a workspace**: click **Choose workspace**, add a project directory, and select it
3. **Run a task**: start a session and type your task. The agent can read and edit workspace files, run commands, delegate subtasks, and maintain a plan; operations requiring approval are confirmed with you first

See the [Web UI guide](docs/user/guide/index.md) and the [model configuration guide](docs/user/guide/providers.md) for details.

### Command line

The desktop package also ships the full `dsh` CLI:

```sh
dsh web                          # start the web UI without the desktop window
dsh --profile headless "task"    # run a task once and print the result
dsh plugin --profile web <pnpm args>  # manage profile plugins
dsh --help                       # show help
```

See the [CLI documentation](apps/cli/README.md) for details.

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

## Repository layout

| Directory | Description |
| --- | --- |
| `apps/cli` | The `dsh` command-line entry point |
| `apps/web` | The web UI |
| `apps/desktop` | Desktop launcher script and deb packaging |
| `packages/` | Framework and feature plugin packages |
| `python/` | Python SDK |
| `examples/` | Agent examples |
| `docs/` | Documentation |

## License

[MIT](LICENSE)

Third-party dependencies and their licenses are disclosed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
