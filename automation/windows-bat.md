---
领域: automation
版本: v1.0
最后更新: 2026-03-30
适用工具: Claude Code
---

# Windows bat 脚本编写与全局命令配置

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.1 | 2026-03-30 | 新增中文编码根本原因分析及 bat+ps1 分离方案 |
| v1.0 | 2026-03-30 | 初始版本 |

## 问题场景

需要在 Windows 命令行中输入一个短命令（如 `weeknews`），自动执行一系列操作（网络请求、文件下载等），且在任意目录下都可触发。

## 解决方案

### Step 1：编写 bat 脚本

bat 脚本基本结构：

```bat
@echo off
setlocal enabledelayedexpansion

:: 获取动态值（如 gh api 返回结果）
for /f "delims=" %%i in ('命令') do set VAR=%%i

:: 判断文件是否已存在
if exist "路径\文件名" (
    echo 已存在，跳过
    pause & exit /b 0
)

:: 执行主逻辑
curl -L -o "目标路径\%VAR%" "%URL%"

pause
```

关键语法：
- `@echo off` — 不回显命令本身
- `setlocal enabledelayedexpansion` — 启用 `!VAR!` 动态变量
- `for /f %%i in ('命令')` — 捕获命令输出到变量
- `%TEMP%\file.txt` — 临时文件中转（处理较长输出）

### Step 2：将 bat 所在目录加入用户 PATH

```powershell
# 查看当前 PATH
[System.Environment]::GetEnvironmentVariable('Path', 'User')

# 追加新目录
[System.Environment]::SetEnvironmentVariable(
  'Path',
  [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';E:\你的目录',
  'User'
)
```

### Step 3：重新打开命令行窗口

PATH 修改对当前窗口不生效，必须重新打开终端。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 变量在 for 循环内取不到值 | 未启用延迟展开 | 加 `setlocal enabledelayedexpansion`，用 `!VAR!` 而非 `%VAR%` |
| PATH 修改后命令还是找不到 | 当前终端窗口不会刷新 PATH | 重新打开终端 |
| curl 下载无进度显示 | Claude 输出环境不支持终端控制字符 | 告知用户在终端自行运行 |
| `'/f' 不是内部或外部命令` | bat 文件保存为 Unix LF 换行，cmd 解析 `for /f` 时将 `/f` 当作独立命令 | 转换为 CRLF（PowerShell：`Get-Content \| Set-Content`） |
| 中文乱码且 `%VAR%` 未展开 | PowerShell `Set-Content` 默认将文件转为 GBK，UTF-8 中文字节破坏了 `%` 等 ASCII 字符 | 重新用 Write 工具写入 |
| 加了 `chcp 65001` 仍然乱码 | **根本原因**：cmd 读取 bat 文件本身用系统 GBK 编码，`chcp` 只影响终端输出，不影响文件读取阶段。UTF-8 中文是多字节序列，GBK 误读时会把后面紧跟的 ASCII 命令字符（`if`/`for`/`%`）一起"吞掉" | **bat 文件中禁止写中文**，全部用英文 |

## 想在 bat 里用中文？改用 bat+ps1 分离方案

bat 文件里写中文必然踩坑。如果需要中文提示，推荐：

**方案：bat 只做入口，逻辑全写在 ps1**

`weeknews.bat`（极简，无中文）：
```bat
@echo off
powershell -ExecutionPolicy Bypass -File "E:\ClaudeCode\WeeklyNews\weeknews.ps1"
```

`weeknews.ps1`（可以自由写中文）：
```powershell
Write-Host "正在获取最新 WeeklyNews..."
# 所有逻辑写这里
```

用户输入 `weeknews` → bat 触发 → 调用 ps1，中文正常显示。

## 相关经验

- [download/gh-api-file-download.md](../download/gh-api-file-download.md) — bat 中调用 gh api 下载文件
