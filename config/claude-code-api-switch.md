# Claude Code 多 API 配置切换方案

**版本**：v1.1 | **日期**：2026-04-08

## 版本历史

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

### ⚠️ 安全警告

**错误示例（会清空所有系统路径）**：
```bat
setx PATH "C:\Users\<用户名>\.claude"  # ❌ 危险！会覆盖原有PATH
```

**正确方法（追加路径）**：
```bat
setx PATH "%PATH%;C:\Users\<用户名>\.claude"  # ✅ 安全，追加到末尾
```

### 事故恢复方法

如果不慎覆盖了PATH导致系统命令失效（如 `winget`、`git` 等无法识别）：

1. **通过 winget 找回 Claude 路径**：
   ```
   C:\Users\<用户名>\AppData\Local\Microsoft\WinGet\Packages\Anthropic.ClaudeCode_Microsoft.Winget.Source_8wekyb3d8bbwe
   ```

2. **手动恢复系统PATH**：
   - 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   - 编辑用户变量 `Path`，逐条添加回常用路径
   - 或重启系统后部分路径可能自动恢复

3. **查看当前PATH配置**：
   ```powershell
   [Environment]::GetEnvironmentVariable('Path', 'User')
   ```

### Git Bash 兼容方案

`.bat` 文件在 Git Bash 中无法直接执行，需创建 shell wrapper：

**创建 `~/.claude/switch-api`（无后缀）**：
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmd.exe /c "$SCRIPT_DIR/switch-api.bat" "$@"
```

**添加执行权限**：
```bash
chmod +x ~/.claude/switch-api
```

执行后新开终端即可全局使用 `switch-api` 命令（PowerShell/CMD/Git Bash 均可）。

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
- **修改系统 PATH 时务必使用追加方式**（`%PATH%;新路径`），避免覆盖原有路径
- PATH 修改后需新开终端才能生效
- 如遇到 PATH 被覆盖，可通过 winget 安装路径找回 Claude，然后手动恢复系统路径

## 经验教训

### PATH 覆盖事故（2026-04-08）

**现象**：执行 `setx PATH "C:\Users\<用户名>\.claude"` 后，系统命令全部失效（`claude`、`winget`、`git` 等无法识别）

**原因**：直接赋值覆盖了原有 PATH，导致所有系统路径丢失

**影响**：用户需手动恢复所有系统路径，虽然功能最终恢复但留下大量重复路径

**预防**：
1. 修改系统级配置前先备份当前值
2. 使用追加语法而非直接赋值
3. 涉及关键环境变量时，先展示命令让用户确认再执行
