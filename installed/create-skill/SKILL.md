---
name: create-skill
description: Use when user says "把这个生成技能" / "写成技能" / "记录成技能" / "保存为技能" / "create skill" / "generate skill" — runs the full 7-step workflow to convert current session experience into a reusable skill file.
---

# 把当前经验生成技能的完整流程

## 七步流程

**第一步：确定内容**
- 技能名（纯英文小写连字符）
- 分类（debugging / data-processing / automation / document / download / config / tools / skills-management）
- description（触发条件，不是内容摘要，不含流程）
- 触发关键词（中英文）

> **环境变量**：`$SKILLS_REPO` = 技能库本地克隆根目录
> - Windows: `E:\ClaudeCode\ClaudeCodeSkills`
> - Linux:    `~/ClaudeCodeSkills`（或实际克隆路径）

**第二步：写 source 文件**
路径：`$SKILLS_REPO/<分类>/<技能名>.md`
按 `_template.md` 格式，含版本日志、问题场景、解决方案、踩坑、相关经验。

**第三步：写 installed 文件**
路径：`$SKILLS_REPO/installed/<技能名>/SKILL.md`
superpowers 格式，frontmatter 含 `name` + `description`（description 只写触发条件）。

**第四步：更新 SKILL_INDEX.md**
在对应分类表格追加一行（文件 / 描述 / 触发关键词）。

**第五步：deploy 到 ~/.claude/skills/**

```bash
mkdir -p ~/.claude/skills/<技能名>
cp "$SKILLS_REPO/installed/<技能名>/SKILL.md" ~/.claude/skills/<技能名>/
```

**第六步：测试**

```bash
head -5 ~/.claude/skills/<技能名>/SKILL.md  # 验证 frontmatter
# 在 Claude Code 中用 Skill tool 调用，确认有内容输出
```

**第七步：推送**

```bash
cd "$SKILLS_REPO"
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
