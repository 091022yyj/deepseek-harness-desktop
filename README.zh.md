# DeepSeek Harness 桌面端

[中文](README.zh.md) | [English](README.md)

DeepSeek Harness 桌面端（`dsh-desktop`）把 DeepSeek Harness 的 Web 界面打包成 Linux 桌面应用：启动后自动在本地拉起服务，并以独立的应用窗口打开，使用体验接近原生桌面程序。

## 特性

- **一键启动**：自动启动本地服务（默认 `http://127.0.0.1:3080`），并打开 Chromium/Chrome 应用窗口
- **独立窗口**：以 `--app` 模式运行，无标签栏与地址栏，界面干净
- **独立配置**：使用专属的 Chromium 配置目录，与日常浏览器互不干扰
- **开箱即用**：安装后可从系统应用菜单或终端启动
- **可定制**：支持通过环境变量配置端口、浏览器与外部服务地址

## 系统要求

- Debian / Ubuntu 等基于 dpkg 的 Linux 发行版（amd64）
- Node.js >= 22
- Google Chrome / Chromium 等 Chromium 系浏览器（可选，缺省时回退到 `xdg-open`）

## 安装

前往 [Releases](../../releases/latest) 页面下载最新版 `deepseek-harness_*.deb` 安装包，然后执行：

```sh
sudo dpkg -i deepseek-harness_0.1.0~rc.5_amd64.deb
```

安装完成后：

- **应用菜单**：在系统应用菜单中找到「DeepSeek Harness 桌面端」并点击
- **命令行**：运行 `dsh-desktop`

## 使用

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

## 从源码构建

```sh
git clone https://github.com/091022yyj/deepseek-harness-desktop.git
cd deepseek-harness-desktop
pnpm install
pnpm run build:lib
pnpm run build:web
bash apps/desktop/build-deb.sh
```

打包产物输出到 `dist/` 目录。

## 许可证

[MIT](LICENSE)

第三方依赖及其许可证见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
