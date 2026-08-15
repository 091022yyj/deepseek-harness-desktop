# DeepSeek Harness 桌面端

[中文](README.zh.md) | [English](README.md)

DeepSeek Harness 桌面端（`dsh-desktop`）是一个 Linux 桌面应用：它将完整的 DeepSeek Harness（`dsh`）智能体框架及其 Web 界面打包安装，启动后自动在本地拉起服务，并以独立的应用窗口打开，获得接近原生桌面程序的体验。

DeepSeek Harness 是一个开源的 agent harness（智能体框架），采用**一切皆插件**的架构：你可以在 Web 界面中配置模型、创建工作区，让智能体读写项目文件、执行命令、委派子任务并维护计划。

## 主要特性

### 桌面端

- **一键启动**：自动启动本地服务（默认 `http://127.0.0.1:3080`），并打开 Chromium/Chrome 应用窗口
- **独立窗口**：以 `--app` 模式运行，无标签栏与地址栏，界面干净
- **独立配置**：使用专属的 Chromium 配置目录，与日常浏览器互不干扰
- **开箱即用**：安装后可从系统应用菜单或终端启动
- **内置运行时**：安装包自带 Node.js，无需另行安装任何依赖
- **可定制**：支持通过环境变量配置端口、浏览器与外部服务地址

### 软件功能

- **Web 界面**：模型配置、工作区管理、会话式智能体对话，支持批准/拒绝敏感操作
- **多模型支持**：DeepSeek API、其他模型服务商以及自定义 OpenAI 兼容端点
- **多种运行模式**：`dsh web`（Web 界面）、`dsh --profile headless "任务"`（无界面单次执行）
- **插件体系**：一切皆插件，通过 `dsh plugin` 管理配置（profile）的插件，为插件仓库添加 [`dsh-plugin`](https://github.com/topics/dsh-plugin) 话题即可被发现
- **Python SDK 与 Agent 示例**：仓库内含 Python SDK 与 ACP / headless / jsonrpc 等 agent 示例

## 系统要求

所有安装包均**内置 Node.js 运行时**，无需自行安装。仅需一个 Chromium 系浏览器（可选，缺省时回退到系统默认浏览器）。

## 安装

前往 [Releases](../../releases/latest) 页面下载对应平台的安装包。

### Windows

下载 `deepseek-harness_*_windows-setup.exe`，双击运行安装。安装完成后可从桌面快捷方式或开始菜单启动「DeepSeek Harness 桌面端」。

### macOS

下载 `deepseek-harness_*_macos-arm64.zip`（Apple 芯片）或 `deepseek-harness_*_macos-x64.zip`（Intel 芯片），解压后双击 `dsh-desktop.command` 启动。若系统提示安全警告，请在「系统设置 → 隐私与安全性」中允许打开。

### Linux（Debian / Ubuntu）

```sh
sudo dpkg -i deepseek-harness_0.1.0~rc.5_amd64.deb
```

安装完成后：

- **应用菜单**：在系统应用菜单中找到「DeepSeek Harness 桌面端」并点击
- **命令行**：运行 `dsh-desktop`

### 通过 npm 运行

安装 `Node.js`，然后运行：

```sh
npx @deepseek-ai/dsh web
```

该命令会启动 Web UI，默认地址为 `http://127.0.0.1:3080`。

## 使用

### 启动桌面端

启动后，桌面端会自动拉起本地服务并打开应用窗口。服务地址默认为 `http://127.0.0.1:3080`，也可以直接在浏览器中访问该地址使用 Web 界面。

支持以下环境变量：

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `DSH_DESKTOP_PORT` | `3080` | 本地服务端口 |
| `DSH_DESKTOP_URL` | `http://127.0.0.1:3080` | 直接连接已存在的服务地址，不再本地启动 |
| `DSH_DESKTOP_BROWSER` | 自动检测 | 指定浏览器，如 `google-chrome`、`chromium` |

日志文件：

- 服务日志：`$XDG_RUNTIME_DIR/dsh-desktop.log`（回退 `/tmp/dsh-desktop.log`）
- 浏览器日志：`$XDG_RUNTIME_DIR/dsh-desktop-browser.log`（回退 `/tmp/dsh-desktop-browser.log`）

### Web 界面入门

1. **配置模型**：打开「设置 → 模型」，填入 API Key 并保存，无需重启即生效
2. **选择工作区**：点击「选择工作区」，添加一个项目目录并选中
3. **运行任务**：新建会话并输入任务，智能体可以读写工作区文件、执行命令、委派子任务并维护计划；需要审批的操作会先征得你的同意

更多说明见 [Web UI 指南](docs/user/guide/index.md)与[模型配置指南](docs/user/guide/providers.md)。

### 命令行

桌面端安装包同时提供完整的 `dsh` 命令行工具：

```sh
dsh web                          # 启动 Web 界面（不打开桌面窗口）
dsh --profile headless "任务"     # 无界面执行一次任务并打印结果
dsh plugin --profile web <pnpm 参数>  # 管理配置的插件
dsh --help                        # 查看帮助
```

详细说明见 [CLI 文档](apps/cli/README.md)。

## 从源码构建

```sh
git clone https://github.com/091022yyj/deepseek-harness-desktop.git
cd deepseek-harness-desktop
pnpm install
pnpm run build:lib
pnpm run build:web
```

构建各平台安装包（首次会从 nodejs.org 下载对应平台的 Node.js 运行时，缓存在 `~/.cache/dsh-build/`）：

```sh
bash apps/desktop/build-deb.sh      # Linux deb
bash apps/desktop/build-windows.sh  # Windows 安装器（需要 makensis）
bash apps/desktop/build-macos.sh    # macOS zip（x64 + arm64）
```

打包产物输出到 `dist/` 目录。

## 目录结构

| 目录 | 说明 |
| --- | --- |
| `apps/cli` | `dsh` 命令行入口 |
| `apps/web` | Web 界面 |
| `apps/desktop` | 桌面端启动脚本与 deb 打包 |
| `packages/` | 框架与各功能插件包 |
| `python/` | Python SDK |
| `examples/` | Agent 示例 |
| `docs/` | 文档 |

## 许可证

[MIT](LICENSE)

第三方依赖及其许可证见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
