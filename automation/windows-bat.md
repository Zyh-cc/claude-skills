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
| 中文路径乱码 | bat 默认 GBK 编码 | 文件路径尽量用英文 |
| curl 下载无进度显示 | Claude 输出环境不支持终端控制字符 | 告知用户在终端自行运行 |

## 相关经验

- [download/gh-api-file-download.md](../download/gh-api-file-download.md) — bat 中调用 gh api 下载文件
