---
name: create-skill
description: Use when the user says "把这个生成技能", "写成技能", "记录成技能", "保存为技能", or asks to turn current session experience into a reusable skill
---

# 生成技能完整流程

技能树路径：`E:\ClaudeCode\ClaudeCodeSkills\`

---

## 第一步：确定内容

从当前对话提炼：
- **技能名**（纯英文小写连字符，如 `open3d-mouse-callbacks`）
- **所属分类**（`debugging` / `data-processing` / `automation` / `document` / `download` / `config` / `tools` / `skills-management`）
- **一句话描述**（触发条件，不是内容摘要）
- **触发关键词**（中英文，用逗号分隔）

> ⚠️ **触发词必须用中文，且要口语化**：用用户实际说话的方式写，不要只写书面术语或英文。
> 例："下载仓库文件" 太书面 → 改为 "下载最新报告"、"直接下载到本地"、"下载推上去的文件"。
> 触发词没命中 = 技能白写，命中率比内容质量更重要。

---

## 第二步：写 source 文件

路径：`E:\ClaudeCode\ClaudeCodeSkills\<分类>\<技能名>.md`

按 `_template.md` 格式，包含：版本日志、问题场景、解决方案、踩过的坑、相关经验。

---

## 第三步：写 installed 文件

路径：`E:\ClaudeCode\ClaudeCodeSkills\installed\<技能名>\SKILL.md`

superpowers 格式，frontmatter 两个字段：

```markdown
---
name: <技能名>
description: Use when <触发条件，不含流程摘要>
---

## 核心内容（命令/代码/规则）
## 踩坑
```

---

## 第四步：更新 SKILL_INDEX.md

在 `E:\ClaudeCode\ClaudeCodeSkills\SKILL_INDEX.md` 对应分类表格追加一行：

```
| [<技能名>.md](<分类>/<技能名>.md) | <一句话描述> | <触发关键词> |
```

---

## 第五步：deploy 到 ~/.claude/skills/

```powershell
$src = "E:\ClaudeCode\ClaudeCodeSkills\installed\<技能名>\SKILL.md"
$dst = "$env:USERPROFILE\.claude\skills\<技能名>"
New-Item -ItemType Directory $dst -Force | Out-Null
Copy-Item $src $dst
```

或在 bash 中：
```bash
mkdir -p ~/.claude/skills/<技能名>
cp "E:/ClaudeCode/ClaudeCodeSkills/installed/<技能名>/SKILL.md" ~/.claude/skills/<技能名>/
```

---

## 第六步：测试能否 load

```bash
# 验证文件存在且 frontmatter 有效
head -5 ~/.claude/skills/<技能名>/SKILL.md
# 应输出 ---\nname: <技能名>\ndescription: ...

# 在 Claude Code 中用 Skill tool 调用
# Skill tool: skill="<技能名>"
# 若输出技能内容则 load 成功
```

---

## 第七步：用女娲技能优化

技能写完后立即调用 `darwin-skill`（女娲技能）对 installed SKILL.md 进行优化：

```
Skill tool: skill="darwin-skill"
目标文件：C:\Users\13613\.claude\skills\<技能名>\SKILL.md
```

优化完成后将结果同步回 source 文件。

---

## 第八步：推送到 GitHub

```bash
cd "E:/ClaudeCode/ClaudeCodeSkills"
git add <分类>/<技能名>.md installed/<技能名>/SKILL.md SKILL_INDEX.md
git commit -m "feat: add <技能名> skill"
git push
```

---

## 检查清单

- [ ] source 文件：有版本日志、问题场景、解决方案、踩坑
- [ ] installed SKILL.md：frontmatter `name` + `description`（description 只写触发条件，不写流程）
- [ ] SKILL_INDEX.md：已追加对应行
- [ ] `~/.claude/skills/<技能名>/SKILL.md` 文件存在
- [ ] `head -5` 验证 frontmatter 格式正确
- [ ] Skill tool 调用成功（不报错、有内容输出）
- [ ] 女娲技能优化完成
- [ ] git push 完成
