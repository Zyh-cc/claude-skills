---
领域: skills-management
版本: v2.0
最后更新: 2026-04-11
适用工具: Claude Code
---

# 技能树自进化系统架构

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v2.0 | 2026-04-11 | 升级为双层结构：source（详细版）+ installed（精简版）|
| v1.1 | 2026-03-30 | MVP 闭环全部实现 |
| v1.0 | 2026-03-30 | 初始架构设计 |

---

## 系统目标

让 Claude 在每次对话中**自动复用已有经验**，并在对话结束后**自动沉淀新经验**，形成持续进化的知识闭环。

---

## 双层技能结构

| 层 | 位置 | 形式 | 加载方式 | 用途 |
|----|------|------|---------|------|
| Source（详细版） | `E:\ClaudeCode\ClaudeCodeSkills\<category>\xxx.md` | 完整 md，含版本日志 | hooks 关键词匹配注入 | 深度经验存档，自动推送相关内容 |
| Installed（精简版） | `C:\Users\<username>\.claude\skills\<name>\SKILL.md` | 官方格式 SKILL.md | Claude Code 自动扫描加载 | 随时可被 Skill 工具调用 |

两层互补：source 层自动推送，installed 层按需调用。

---

## 三层加载机制

```
[用户发消息]
     ↓
UserPromptSubmit hook
     ↓ 关键词匹配 source 技能文件 keywords 字段
有匹配 → 注入完整内容到 Claude 上下文（~300-500 token）
无匹配 → 0 额外 token
     ↓
[Claude 执行任务]
     ↓
Claude 判断是否需要 installed 技能 → Skill 工具调用
     ↓
Stop hook
     ↓
提示用户：是否有新经验？更新技能树并同步 GitHub
```

---

## 技能来源（四类）

| 来源 | 数量 | 加载方式 |
|------|------|---------|
| `~/.claude/plugins/` superpowers | 14 | settings.json enabledPlugins |
| `~/.claude/plugins/` document-skills | 17 | settings.json enabledPlugins |
| `~/.claude/skills/`（个人 installed） | 12+ | 自动扫描目录 |
| `E:\ClaudeCode\ClaudeCodeSkills\`（source） | 15+ | hooks 注入 |

---

## Hook 脚本位置

- `E:\ClaudeCode\ClaudeCodeSkills\hooks\session-start.ps1` — SessionStart
- `E:\ClaudeCode\ClaudeCodeSkills\hooks\user-prompt.ps1` — UserPromptSubmit 关键词匹配

## 关键词机制

每个 source 技能文件 frontmatter 中有 `keywords:` 字段（纯 ASCII）：
```yaml
keywords: bat, script, cmd, path, windows, crlf, encoding
```
user-prompt.ps1 提取用户消息 → 与 keywords 匹配 → 注入命中文件内容。

## 重要坑

- Claude Code hook 不支持 `shell: "powershell"`，必须用默认 bash
- 复杂逻辑写入外部 `.ps1` 文件，bash 用 `powershell -ExecutionPolicy Bypass -File` 调用
- Hook 命令 JSON 中不能含中文字符

---

## GitHub 仓库结构

```
claude-skills/
├── <category>/xxx.md     ← source 详细版（含版本日志）
├── installed/<name>/SKILL.md  ← 精简版（对应 ~/.claude/skills/）
├── hooks/                ← hook 脚本
└── README.md             ← 含完整部署和维护文档
```

## 相关经验

- [automation/claude-hooks.md](../automation/claude-hooks.md) — Hook 配置与 PowerShell 调用方式
- [skills-management/skill-lifecycle.md](./skill-lifecycle.md) — 新增/更新技能标准流程
