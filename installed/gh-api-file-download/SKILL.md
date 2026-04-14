---
name: gh-api-file-download
description: Download files committed directly to a GitHub repository directory (not release assets) using gh api. Use this when the user wants to fetch a file that lives inside a repo folder — reports, generated docs, data files — not from the Releases page. Triggers on: "下载仓库文件", "从GitHub下载文件", "gh api下载", "contents API", "download_url", "下载最新报告", "拉取最新文件", "直接下载到本地", "从仓库下载", "下载推上去的文件".
---

## Recommended approach: gh api contents

```bash
# List files in directory, get latest by name sort
gh api repos/<owner>/<repo>/contents/<path> \
  --jq "[.[] | .name] | sort | reverse | .[0]"

# Get download URL for a specific file
gh api repos/<owner>/<repo>/contents/<path>/<filename> \
  --jq ".download_url"

# Download
curl -L -o "local/path/filename" "<download_url>"
```

## Automate with bat (Windows)

```bat
@echo off
for /f "delims=" %%i in ('gh api repos/<owner>/<repo>/contents/<path> --jq "[.[] | .name] | sort | reverse | .[0]"') do set LATEST=%%i
gh api repos/<owner>/<repo>/contents/<path>/%LATEST% --jq ".download_url" > %TEMP%\url.txt
set /p URL=<%TEMP%\url.txt
curl -L -o "target\%LATEST%" "%URL%"
```

## PowerShell 推荐写法（更可靠）

**不要在 PowerShell 里用 `--jq`**：排序结果和类型转换行为不可预期，改用 `ConvertFrom-Json` 在 PS 里过滤。

```powershell
# 获取目录下最新 docx
$files = gh api repos/<owner>/<repo>/contents/<path> | ConvertFrom-Json
$latest = $files | Where-Object { $_.name -like "*.docx" } | Sort-Object name -Descending | Select-Object -First 1

# 下载（Windows 用 Invoke-WebRequest，不用 curl）
$localFile = Join-Path $targetDir $latest.name
Invoke-WebRequest -Uri $latest.download_url -OutFile $localFile
```

## vs gh release

| Scenario | Tool |
|----------|------|
| File in GitHub Releases Assets | `gh release view --json assets` |
| File committed in repo directory | `gh api repos/.../contents/...` |

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `download_url` is null | File >1MB, contents API omits content | Use `git.url` or clone the repo |
| Chinese filename URL encoding errors | curl doesn't auto-encode | Use English+date filenames |
| 403 on private repo | Not logged in or token lacks repo scope | Run `gh auth login` first; or set `GH_TOKEN` |
