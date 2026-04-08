# Claude Code 多 API 配置切换方案

**版本**：v1.0 | **日期**：2026-04-08

## 适用场景

官方订阅额度不足时，需要临时切换到第三方中转 API（如 Foxcode），并能随时切回官方账号。

## 核心原理

Claude Code 通过 `settings.json` 的 `env` 字段注入环境变量，关键变量：

| 变量 | 作用 |
|------|------|
| `ANTHROPIC_AUTH_TOKEN` | 覆盖 API Key |
| `ANTHROPIC_BASE_URL` | 覆盖 API 请求地址 |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | 禁用非必要流量（中转站推荐开启） |

## 实现方案

### 文件布局

```
~/.claude/
├── settings.json               # 当前生效配置（脚本管理）
├── settings.foxcode.json       # 中转站配置
├── settings.official.json      # 官方账号配置（最简，只保留 permissions）
└── switch-api.bat              # 切换脚本
```

### settings.foxcode.json

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "<中转站 API Key>",
    "ANTHROPIC_BASE_URL": "<中转站地址>",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

### settings.official.json

```json
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

### switch-api.bat（支持命令行参数 + 交互式菜单）

```bat
@echo off
setlocal

set CLAUDE_DIR=%~dp0

if "%1"=="foxcode" goto foxcode
if "%1"=="official" goto official
if "%1"=="" goto interactive

echo 用法: switch-api [foxcode^|official]
exit /b 1

:interactive
echo Claude Code API 切换工具
echo ========================
echo 1. Foxcode 中转站
echo 2. 官方账号
echo.
set /p choice=请选择 (1/2):
if "%choice%"=="1" goto foxcode
if "%choice%"=="2" goto official
echo 无效选择
exit /b 1

:foxcode
copy /y "%CLAUDE_DIR%settings.foxcode.json" "%CLAUDE_DIR%settings.json" >nul
echo [OK] 已切换到 Foxcode 中转站（重启 Claude Code 生效）
exit /b 0

:official
copy /y "%CLAUDE_DIR%settings.official.json" "%CLAUDE_DIR%settings.json" >nul
echo [OK] 已切换到官方账号（重启 Claude Code 生效）
exit /b 0
```

## 加入系统 PATH

```bat
setx PATH "%PATH%;C:\Users\<用户名>\.claude"
```

执行后新开终端即可全局使用 `switch-api` 命令。

## 使用命令

```bat
switch-api foxcode     # 切换到中转站
switch-api official    # 切换到官方
switch-api             # 交互式选择
```

## 注意事项

- 切换后需**重启 Claude Code** 生效
- `settings.json` 由脚本管理，不要手动编辑
- API Key 敏感，`settings.foxcode.json` 不要上传公开仓库
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` 值需为字符串 `"1"`，不能是数字 `1`
