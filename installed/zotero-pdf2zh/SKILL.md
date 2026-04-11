---
name: zotero-pdf2zh
description: Set up and start the zotero-pdf2zh translation plugin local server. Use this when the user mentions Zotero PDF translation not working, pdf2zh, or needs to start the local translation server on port 8890.
---

## Setup (first time)

Local paths on this machine:
- Server dir: `D:\zotero\server\`
- Venv: `D:\zotero\server\zotero-pdf2zh-venv\`
- Launcher: `D:\zotero\server\pdf2zh.bat`

```powershell
# Install uv
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Create venv and install dependencies
$env:Path = 'C:\Users\13613\.local\bin;' + $env:Path
cd D:\zotero\server
uv venv zotero-pdf2zh-venv --python=3.12
uv pip install -p D:\zotero\server\zotero-pdf2zh-venv\Scripts\python.exe `
  "pdf2zh==1.9.11" pypdf PyMuPDF flask "numpy==2.2.0" toml "pdfminer.six==20250416" packaging
```

## Daily use

```cmd
D:\zotero\server\pdf2zh.bat
```

Then in Zotero: Tools → Plugins → zotero-pdf2zh → Check connection.

## pdf2zh.bat content

```bat
@echo off
cd /d D:\zotero\server
start "zotero-pdf2zh server" D:\zotero\server\zotero-pdf2zh-venv\Scripts\python.exe server.py
echo Server started on port 8890
```

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Tsinghua PyPI mirror timeout | Slow mirror, ~120s timeout | Use official source (no `--index-url`) |
| install bat doesn't start server | install ≠ start | Run server.py separately after install |
| `uv` not found | PATH not updated | New terminal or `$env:Path = 'C:\Users\13613\.local\bin;...'` |
