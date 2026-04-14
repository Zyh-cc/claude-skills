---
name: windows-bat
description: Write Windows bat scripts and add them as global commands. Use this whenever creating a .bat file, adding a directory to Windows PATH, or debugging bat script issues like encoding errors, variable expansion problems, or CRLF issues. Triggers on: "bat脚本", "写bat", "bat文件", "全局命令", "添加PATH", "bat中文乱码", "变量展开", "for /f".
---

## Basic bat structure

```bat
@echo off
setlocal enabledelayedexpansion

:: Capture command output into variable
for /f "delims=" %%i in ('some-command') do set VAR=%%i

:: Check file existence
if exist "path\file" (
    echo already exists
    pause & exit /b 0
)

:: Main logic
curl -L -o "target\%VAR%" "%URL%"
pause
```

Key syntax:
- `@echo off` — suppress command echo
- `setlocal enabledelayedexpansion` — enable `!VAR!` dynamic variables
- `for /f %%i in ('cmd')` — capture command output
- Use `%TEMP%\file.txt` as intermediate for long outputs

## Add bat directory to PATH (PowerShell)

```powershell
# View current PATH
[System.Environment]::GetEnvironmentVariable('Path', 'User')

# Append new directory (NEVER overwrite — that deletes all other paths)
[System.Environment]::SetEnvironmentVariable(
  'Path',
  [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';E:\your\dir',
  'User'
)
```

Restart terminal after PATH change — current window won't refresh.

## Chinese text in bat: use bat+ps1 split

**Never write Chinese in .bat files** — GBK encoding at parse time corrupts multibyte chars and swallows adjacent ASCII commands.

```bat
@echo off
powershell -ExecutionPolicy Bypass -File "E:\path\script.ps1"
```

```powershell
# script.ps1 — Chinese text fine here
Write-Host "正在处理..."
```

## ps1 文件编码：必须 UTF-8 BOM

PowerShell 默认以 ANSI 读取 ps1，中文会乱码。必须用 UTF-8 BOM 写入：

```powershell
# 正确写法（带 BOM）
[System.IO.File]::WriteAllText('path\script.ps1', $content, [System.Text.UTF8Encoding]::new($true))
```

**不要用 PowerShell `-Command` heredoc 写 ps1**：`$` 需要反引号转义，转义符会残留在文件里，导致字符串拼接出现非法字符。应直接用编辑器或 Write 工具写文件。

## 路径拼接：用 Join-Path

```powershell
# 错误：字符串拼接易出现非法字符
$path = "$dir\$file"

# 正确
$path = Join-Path $dir $file
```

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Variable empty inside for loop | Delayed expansion not enabled | Add `setlocal enabledelayedexpansion`, use `!VAR!` |
| Command not found after PATH change | Current terminal doesn't reload PATH | Open new terminal |
| `'/f' is not a command` | bat saved with Unix LF | Convert to CRLF |
| Chinese chars corrupt adjacent commands | GBK reads UTF-8 multibyte, eats ASCII | No Chinese in bat files |
| Relative paths break when bat is called from another dir | CWD changes, not bat's location | Use `%~dp0` prefix: `%~dp0script.ps1` always resolves to the bat's own directory |
| Chinese garbled in ps1 | ps1 saved without BOM | Use `UTF8Encoding($true)` when writing |
| Path has illegal characters in ps1 | `$` escaping in heredoc leaves backtick in file | Write ps1 directly with Write tool, not via heredoc |
