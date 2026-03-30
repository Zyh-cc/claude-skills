---
领域: skills-management
版本: v1.1
最后更新: 2026-03-30
适用工具: Claude Code
---

# 技能树自进化系统架构

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.1 | 2026-03-30 | MVP 闭环全部实现，更新状态与架构说明 |
| v1.0 | 2026-03-30 | 初始架构设计，记录三层进化路线与核心待解决问题 |

---

## 系统目标

让 Claude 在每次对话中**自动复用已有经验**，并在对话结束后**自动沉淀新经验**，形成持续进化的知识闭环。不依赖 Claude 的"自觉"，而是通过系统机制强制执行。

---

## 三层进化路线

| 阶段 | 机制 | 状态 |
|------|------|------|
| 第一层：提醒存在 | SessionStart hook → 告知技能库文件列表 | ✅ 已完成 |
| 第二层：自动检索 | UserPromptSubmit hook → 关键词匹配 → 注入相关技能内容 | ✅ 已完成 |
| 第三层：自动沉淀 | Stop hook → 提示用户是否更新技能库 | ✅ 已完成 |

---

## 当前架构（已实现）

```
[用户发消息]
     ↓
UserPromptSubmit hook
     ↓ 关键词匹配技能文件 keywords 字段
有匹配 → 注入文件内容到 Claude 上下文
无匹配 → 0 额外 token
     ↓
[Claude 执行任务，相关经验已在上下文中]
     ↓
Stop hook
     ↓
显示提示：是否有新经验？更新技能库并同步 GitHub
     ↓
[技能库更新，下次可用]
```

---

## 实现细节

### Hook 脚本位置
- `E:\ClaudeCode\ClaudeCodeSkills\hooks\session-start.ps1` — SessionStart 逻辑
- `E:\ClaudeCode\ClaudeCodeSkills\hooks\user-prompt.ps1` — UserPromptSubmit 关键词匹配逻辑

### 关键词机制
每个技能文件 frontmatter 中有 `keywords:` 字段（纯 ASCII），例如：
```yaml
keywords: bat, script, cmd, path, windows, crlf, encoding
```
user-prompt.ps1 提取用户消息 → 与 keywords 匹配 → 注入命中文件内容。

### Token 消耗策略
- 无匹配：0 额外 token
- 有匹配：仅注入命中文件（1-2 个，~300-500 token）
- 不做全量注入，避免上下文膨胀

### 重要坑
- Claude Code 当前版本 hook 不支持 `shell: "powershell"`，必须用默认 bash
- 复杂逻辑写入外部 `.ps1` 文件，bash 用 `powershell -ExecutionPolicy Bypass -File` 调用
- Hook 命令 JSON 中不能含中文字符，否则编码问题导致命令损坏

---

## 已完成的基础设施

- `E:\ClaudeCode\ClaudeCodeSkills\` — 技能库目录（含 `keywords:` 字段）
- `E:\ClaudeCode\ClaudeCodeSkills\hooks\` — Hook 脚本目录
- `~/.claude/CLAUDE.md` — 强制工作流规则
- `~/.claude/settings.json` — 三个 hook 配置（SessionStart / UserPromptSubmit / Stop）
- `E:\ClaudeCode\ClaudeLogs\` — 对话日志

---

## 下一步优化方向（非 MVP，按需推进）

1. **匹配精度提升**：当前仅匹配 ASCII 关键词，中文关键词需要额外处理
2. **UserPromptSubmit 性能**：文件增多后考虑建立索引文件加速匹配
3. **Stop hook 智能化**：当前只做提示，未来可尝试自动判断是否产生新经验

## 相关经验

- [automation/claude-hooks.md](../automation/claude-hooks.md) — Hook 配置与 PowerShell 调用方式
