---
领域: tools
版本: v1.0
最后更新: 2026-04-09
适用工具: Claude Code
---

# zotero-pdf2zh 插件安装与本地 server 启动

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-09 | 初始版本 |

## 问题场景

在 Zotero 中安装 zotero-pdf2zh 翻译插件后，翻译功能无法使用。
原因：该插件依赖本地 Python server（默认端口 8890），不启动 server 则插件无响应。

## 解决方案

### 推荐方案：uv 虚拟环境 + start.bat 一键启动

**关键路径（本机）**
- server 目录：`D:\zotero\server\`
- 虚拟环境：`D:\zotero\server\zotero-pdf2zh-venv\`
- 启动脚本：`D:\zotero\server\pdf2zh.bat`
- 插件版本：v4.0.1，来源：https://github.com/Zyh-cc/zotero-pdf2zh

**首次安装步骤**

1. 安装 uv（PowerShell）：
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

2. 创建虚拟环境并安装依赖（在 `D:\zotero\server\` 下执行）：
```powershell
$env:Path = 'C:\Users\13613\.local\bin;' + $env:Path
uv venv zotero-pdf2zh-venv --python=3.12
uv pip install -p D:\zotero\server\zotero-pdf2zh-venv\Scripts\python.exe `
  "pdf2zh==1.9.11" pypdf PyMuPDF flask "numpy==2.2.0" toml "pdfminer.six==20250416" packaging
```

3. 创建启动脚本 `D:\zotero\server\pdf2zh.bat`：
```bat
@echo off
cd /d D:\zotero\server
start "zotero-pdf2zh server" D:\zotero\server\zotero-pdf2zh-venv\Scripts\python.exe server.py
echo Server started on port 8890
```

**日常使用**

每次使用翻译前，在命令行运行：
```cmd
D:\zotero\server\pdf2zh.bat
```

然后在 Zotero → 工具 → 插件 → zotero-pdf2zh 设置 → 点"检查连接"验证。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 清华 PyPI 镜像超时 | 镜像响应慢，uv 默认超时约 120s | 改用官方源（不加 `--index-url`） |
| install-with-uv.bat 只负责安装不负责启动 | bat 名称误导 | 安装完后需单独运行 `server.py` |
| uv 安装后找不到命令 | PATH 未更新 | 新开终端或手动 `$env:Path = 'C:\Users\13613\.local\bin;...'` |

## 相关经验

- [github-release 下载](../download/github-release.md) — 从 GitHub 仓库直接下载 xpi 文件
