---
领域: skills-management
版本: v1.0
最后更新: 2026-04-13
适用工具: Claude Code
keywords: 把这个生成技能, 写成技能, 记录成技能, 保存为技能, create skill, generate skill
---

# 把当前经验生成技能的完整流程

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-13 | 初始版本，整理自实际操作经验 |

## 问题场景

用户说"把这个生成技能"/"写成技能"等，需要将当前对话经验固化为可复用技能，
走完从 source 文件 → installed → SKILL_INDEX → deploy → 测试 → push 的完整流程。

## 解决方案

### 七步流程

**第一步：确定内容**
- 技能名（纯英文小写连字符）
- 分类（debugging / data-processing / automation / document / download / config / tools / skills-management）
- description（触发条件，不是内容摘要，不含流程）
- 触发关键词（中英文）

**第二步：写 source 文件**
路径：`E:\ClaudeCode\ClaudeCodeSkills\<分类>\<技能名>.md`
按 `_template.md` 格式，含版本日志、问题场景、解决方案、踩坑、相关经验。

**第三步：写 installed 文件**
路径：`E:\ClaudeCode\ClaudeCodeSkills\installed\<技能名>\SKILL.md`
superpowers 格式，frontmatter 含 `name` + `description`（description 只写触发条件）。

**第四步：更新 SKILL_INDEX.md**
在对应分类表格追加一行（文件 / 描述 / 触发关键词）。

**第五步：deploy 到 ~/.claude/skills/**
```bash
mkdir -p ~/.claude/skills/<技能名>
cp "E:/ClaudeCode/ClaudeCodeSkills/installed/<技能名>/SKILL.md" ~/.claude/skills/<技能名>/
```

**第六步：测试**
```bash
head -5 ~/.claude/skills/<技能名>/SKILL.md   # 验证 frontmatter
# 在 Claude Code 中用 Skill tool 调用，确认有内容输出
```

**第七步：推送**
```bash
cd "E:/ClaudeCode/ClaudeCodeSkills"
git add <分类>/<技能名>.md installed/<技能名>/SKILL.md SKILL_INDEX.md
git commit -m "feat: add <技能名> skill"
git push
```

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| description 写成了流程摘要 | 以为 description 是"说明内容" | description 只写触发条件（Use when...），流程写在 body |
| 只部署了 installed/ 没有 deploy 到 ~/.claude/skills/ | 两步容易漏 | 检查清单：installed/ 和 ~/.claude/ 都要写 |
| Skill tool 不能 load | frontmatter 格式错误（缩进/引号） | 用 `head -5` 验证，确保 `---\nname: ...\ndescription: ...` |
| SKILL_INDEX.md 忘记更新 | 认为只要部署就够了 | 索引决定下次会话能否被发现，必须更新 |

## 相关经验

- [skill-lifecycle.md](skill-lifecycle.md) — 技能更新和归档规范
- [skill-tree-architecture.md](skill-tree-architecture.md) — 目录结构设计原则
