# deepseek-harness-desktop

给 DeepSeek Harness (dsh) 套上 Linux 桌面壳：deb 包一键安装，双击图标即启动本地服务并弹出独立 Chromium 窗口。不用再在浏览器几十个标签页里找 localhost:3080——独立窗口、应用菜单、退出自动清理服务进程，桌面体验拉满。

![Version](https://img.shields.io/github/v/release/091022yyj/deepseek-harness-desktop)
![License](https://img.shields.io/github/license/091022yyj/deepseek-harness-desktop)
![Language](https://img.shields.io/badge/Language-TypeScript-3178C6)
![Platform](https://img.shields.io/badge/Platform-Linux%20(deb)-orange)

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 📦 deb 一键安装 | `dpkg -i` 装完即用，自动创建应用菜单图标 |
| ⚡ 一键启动 | 同时拉起 dsh 本地服务 + 独立 Chromium 窗口 |
| 🪟 独立窗口 | 独立 Chromium 实例，不混入日常浏览器标签页 |
| 🧩 环境变量 | 通过配置文件注入 API Key、端口等环境变量 |
| 🔄 进程托管 | 窗口关闭自动停止后台服务，不留孤儿进程 |
| 🖼️ 桌面集成 | 应用菜单入口 + 托盘控制，开箱即用 |

## 📸 截图

| 主窗口 | 环境变量配置 | 托盘菜单 |
|--------|--------------|----------|
| ![主窗口](docs/screenshot-main.png) | ![配置](docs/screenshot-settings.png) | ![托盘](docs/screenshot-tray.png) |

## 🚀 快速开始

```bash
# 1. 下载最新 deb 安装包
wget https://github.com/091022yyj/deepseek-harness-desktop/releases/latest/download/deepseek-harness-desktop_amd64.deb
# 2. 安装
sudo dpkg -i deepseek-harness-desktop_amd64.deb
# 3. 从应用菜单启动，或命令行直接运行
deepseek-harness-desktop
```

## ❓ FAQ

**Q: 需要先安装 dsh 吗？**
A: 不需要，安装包已内置 DeepSeek Harness，开箱即用。

**Q: 怎么配置 API Key 和端口？**
A: 编辑 `~/.config/deepseek-harness/env`，支持 `DEEPSEEK_API_KEY`、`PORT` 等变量，保存后重启生效。

**Q: 支持哪些发行版？**
A: Ubuntu 22.04+ / Debian 12+（deb 包）；其他发行版可通过源码构建。

**Q: 如何卸载？**
A: `sudo apt remove deepseek-harness-desktop`，配置目录不会被删除。

## 🏷️ 推荐 Topics

`deepseek` `deepseek-harness` `linux` `desktop-app` `typescript` `chromium` `ai-tools` `productivity`
