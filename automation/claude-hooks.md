---
领域: automation
版本: v1.0
最后更新: 2026-03-30
适用工具: Claude Code
keywords: hook, hooks, settings, sessionstart, userpromptsubmit, stop, powershell, shell
---

# Claude Code Hooks 配置经验

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-30 | 初始版本，记录 hook 配置方式与 PowerShell 不可用问题 |

## Hook 配置基础

Hook 写在 `~/.claude/settings.json` 的 `hooks` 字段中：

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "..." }] }]
  }
}
```

常用事件：

| 事件 | 触发时机 |
|------|---------|
| `SessionStart` | 会话开始时 |
| `UserPromptSubmit` | 用户每次发送消息时 |
| `Stop` | Claude 回答结束时 |
| `PostToolUse` | 工具调用完成后 |

## 向 Claude 注入上下文

通过 `hookSpecificOutput.additionalContext` 将内容注入 Claude 上下文（Claude 能看到，用户看不到）：

```bash
# bash hook 输出此 JSON 即可注入
echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "你想注入的内容"}}'
```

## 向用户显示消息

通过 `systemMessage` 在界面上显示提示（用户能看到）：

```bash
echo '{"systemMessage": "提示内容"}'
```

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| `shell: "powershell"` 报错：`PowerShell hooks are not available in this build` | 当前版本 Claude Code 不支持 hook 的 `shell` 字段设为 `powershell` | 删除 `shell` 字段（默认 bash），复杂逻辑写入 `.ps1` 文件，bash 用 `powershell -ExecutionPolicy Bypass -File` 调用 |
| Hook 命令含中文字符导致乱码或解析失败 | JSON 文件保存 UTF-8，但 Windows 工具链读取时编码不一致 | hook 命令中只用 ASCII，中文逻辑放入外部脚本文件 |
| `UserPromptSubmit` 读取不到 stdin | bash 直接读取时时序问题 | 用 `cat \|` 管道显式传入：`cat \| powershell -File script.ps1` |

## 推荐结构：外部脚本 + bash 调用

复杂逻辑不要内联在 JSON 里，提取为外部脚本：

```
E:\ClaudeCode\ClaudeCodeSkills\hooks\
├── session-start.ps1    # SessionStart 逻辑
├── user-prompt.ps1      # UserPromptSubmit 逻辑
```

settings.json 保持简洁：

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "powershell -ExecutionPolicy Bypass -File 'E:\\path\\session-start.ps1'" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "cat | powershell -ExecutionPolicy Bypass -File 'E:\\path\\user-prompt.ps1'" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "echo '{\"systemMessage\": \"提示内容\"}'" }] }]
  }
}
```

## 相关经验

- [automation/windows-bat.md](./windows-bat.md) — Windows 脚本编写与编码问题
- [skills-management/skill-tree-architecture.md](../skills-management/skill-tree-architecture.md) — 技能树 hook 整体设计
