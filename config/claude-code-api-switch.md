# Claude Code 多 API 配置切换方案

**版本**：v1.2 | **日期**：2026-04-11

## 版本历史

- **v1.2** (2026-04-11)：新增 claudep.bat 自动检测模式、bat 集中到 C:\TOOLS 的路径硬编码方案、ECONNRESET 根因说明、PowerShell 调用 bat 的编码方案
- **v1.1** (2026-04-08)：新增 PATH 修改安全指南、Git Bash 兼容方案、事故恢复方法
- **v1.0** (2026-04-08)：初始版本

## 适用场景

官方订阅额度不足时，需要临时切换到第三方中转 API（如 Foxcode），并能随时切回官方账号。

## 核心原理

Claude Code 通过 `settings.json` 的 `env` 字段注入环境变量，关键变量：

| 变量 | 作用 |
|------|------|
| `ANTHROPIC_AUTH_TOKEN` | 覆盖 API Key |
| `ANTHROPIC_BASE_URL` | 覆盖 API 请求地址 |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | 禁用非必要流量（中转站推荐开启） |

## 中转站原理

中转站是第三方搭建的代理服务器，帮用户"预先翻好墙"：

```
Claude Code → code.newcli.com（中转站，境外服务器）→ api.anthropic.com
```

**使用中转站时绝对不能同时开代理**，否则请求路径变为：
```
Claude Code → Clash Verge → code.newcli.com → api.anthropic.com
```
双重代理会导致频繁 `ECONNRESET` 错误。

## 文件布局

```
C:\TOOLS\
├── claudep.bat         # 启动 Claude Code（自动检测模式）
└── switch-api.bat      # API 切换脚本

~/.claude/
├── settings.json               # 当前生效配置（脚本管理，勿手动编辑）
├── settings.foxcode.json       # 中转站配置
└── settings.official.json      # 官方账号配置
```

## claudep.bat（自动检测模式）

启动时检测 `settings.json` 中是否有 `ANTHROPIC_BASE_URL`：
- **有** → foxcode 模式，跳过代理，直接启动
- **没有** → 官方模式，设置代理，检测 api.anthropic.com，再启动

```bat
@echo off
title Claude Code
color 0A

:: Detect active mode by checking if ANTHROPIC_BASE_URL is set in settings.json
findstr /c:"ANTHROPIC_BASE_URL" "%USERPROFILE%\.claude\settings.json" >nul 2>&1
if %errorlevel% equ 0 goto foxcode_mode

:: ── Official Account Mode ────────────────────────────────────────────────────
:official_mode
title Claude Code (Official)
echo [Mode] Official Account - Clash Verge required (port 7897)
echo.
echo [1/3] Setting proxy environment variables...
set HTTP_PROXY=http://127.0.0.1:7897
set HTTPS_PROXY=http://127.0.0.1:7897
set NO_PROXY=localhost,127.0.0.1
echo [2/3] Verifying connection to Anthropic...
curl -I -s --connect-timeout 5 https://api.anthropic.com | findstr "HTTP/"
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Cannot connect. Please check if Clash Verge is running on port 7897.
    pause
    exit /b
)
echo [3/3] Starting Claude Code...
echo -----------------------------------------------------------------------
claude %*
goto end

:: ── Foxcode Relay Mode ───────────────────────────────────────────────────────
:foxcode_mode
title Claude Code (Foxcode Relay)
echo [Mode] Foxcode Relay - no proxy needed
echo -----------------------------------------------------------------------
claude %*

:end
if %errorlevel% neq 0 (
    echo.
    echo [Program exited with error code %errorlevel%]
    pause
)
```

## switch-api.bat（放在 C:\TOOLS 时用硬编码路径）

**注意**：`%~dp0` 是"bat 文件自身所在目录"。若 bat 放在 `C:\TOOLS` 但 settings json 在 `~\.claude\`，必须硬编码，否则找不到 json 文件。

```bat
@echo off
setlocal

set CLAUDE_DIR=C:\Users\13613\.claude\

if "%1"=="foxcode" goto foxcode
if "%1"=="official" goto official
if "%1"=="" goto interactive

echo Usage: switch-api [foxcode^|official]
exit /b 1

:interactive
echo Claude Code API Switcher
echo ========================
echo 1. Foxcode Proxy
echo 2. Official Account
echo.
set /p choice=Select (1/2):
if "%choice%"=="1" goto foxcode
if "%choice%"=="2" goto official
echo Invalid choice
exit /b 1

:foxcode
copy /y "%CLAUDE_DIR%settings.foxcode.json" "%CLAUDE_DIR%settings.json" >nul
echo [OK] Switched to Foxcode (restart Claude Code to apply)
exit /b 0

:official
copy /y "%CLAUDE_DIR%settings.official.json" "%CLAUDE_DIR%settings.json" >nul
echo [OK] Switched to Official (restart Claude Code to apply)
exit /b 0
```

## settings.foxcode.json

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "<中转站 API Key>",
    "ANTHROPIC_BASE_URL": "<中转站地址>",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "permissions": { "allow": [], "deny": [] },
  "enabledPlugins": { ... },
  "hooks": { ... }
}
```

## settings.official.json

```json
{
  "permissions": { "allow": [], "deny": [] },
  "enabledPlugins": { ... },
  "hooks": { ... }
}
```

**注意**：`enabledPlugins` 和 `hooks` 两个配置文件都要保持同步，否则切换后插件/hook 会丢失。

## 使用命令

```bat
switch-api foxcode     # 切换到中转站
switch-api official    # 切换到官方
switch-api             # 交互式选择
```

切换后需**重启 Claude Code** 生效。

## 从 bash 工具调用 bat（编码问题）

`cmd.exe /c` 调用 bat 时，Windows 系统头信息（版本号、路径等含中文）会乱码。

**正确方式**：
```bash
powershell.exe -Command "& 'C:\TOOLS\switch-api.bat' foxcode"
```

PowerShell 输出编码正常，无乱码。

## 加入系统 PATH

**正确方法（追加路径）**：
```bat
setx PATH "%PATH%;C:\TOOLS"
```

⚠️ 直接赋值 `setx PATH "C:\TOOLS"` 会清空所有系统路径，造成 `claude`、`git`、`winget` 等全部失效。

### 事故恢复方法

1. Claude 安装路径：
   ```
   C:\Users\<用户名>\AppData\Local\Microsoft\WinGet\Packages\Anthropic.ClaudeCode_Microsoft.Winget.Source_8wekyb3d8bbwe
   ```
2. 右键"此电脑" → 属性 → 高级系统设置 → 环境变量，手动恢复路径
3. 查看当前 PATH：
   ```powershell
   [Environment]::GetEnvironmentVariable('Path', 'User')
   ```

## 注意事项

- `settings.json` 由脚本管理，不要手动编辑
- API Key 敏感，`settings.foxcode.json` 不要上传公开仓库
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` 值需为字符串 `"1"`，不能是数字 `1`
- 修改系统 PATH 务必使用追加方式
