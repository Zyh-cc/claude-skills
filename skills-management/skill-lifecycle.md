---
领域: skills-management
版本: v2.0
最后更新: 2026-04-11
适用工具: Claude Code
keywords: skill, install, hotreload, npx, unknown, 安装, 热加载, 找不到, 新建技能, 更新技能, 技能模板
---

# Skill 生命周期管理

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v2.0 | 2026-04-11 | 升级为双层结构标准流程（source + installed）|
| v1.0 | 2026-03-30 | 初始版本 |

---

## 新增技能（标准流程）

1. **创建 source 文件**：复制 `_template.md` 到 `<category>/<skill-name>.md`，填写问题场景/解决方案/踩坑
2. **添加 keywords**：frontmatter 中加 `keywords:` 字段（纯 ASCII），供 hook 关键词匹配
3. **创建 installed 版本**：在 `installed/<skill-name>/SKILL.md` 写精简版（无版本日志，只保留实用命令和踩坑）
4. **更新索引**：在 `SKILL_INDEX.md` 新增一行
5. **部署**：复制 `installed/<skill-name>/SKILL.md` 到 `C:\Users\<username>\.claude\skills\<skill-name>\SKILL.md`
6. **推送 GitHub**：`git add . && git commit -m "feat: add <skill-name>" && git push`

## 更新已有技能

1. 编辑 **source 文件**（完整版，记录版本日志）
2. 更新 **installed 版本**（同步相关命令变更）
3. 复制到 `~/.claude/skills/<name>/SKILL.md`
4. 推送 GitHub

## 两种文件格式对比

**Source（详细版）**：
```markdown
---
领域: category
版本: v1.0
最后更新: YYYY-MM-DD
keywords: keyword1, keyword2   # ASCII only
---
## 版本日志
## 问题场景
## 解决方案
## 踩过的坑
## 相关经验
```

**Installed（精简版）**：
```markdown
---
name: skill-name
description: 触发时机和用途描述（pushy style，让 Claude 主动调用）
---
## 核心命令/流程
## Pitfalls
```

---

## Skill 热加载问题

安装 skill 后在当前 session 中用 `Skill` 工具调用提示「Unknown skill」。

**原因**：session 启动时 skill 列表已固定，新安装不会热加载。

**解决**：
- 推荐：重启 session
- 备选：手动读取 `SKILL.md`，按其中命令操作

## 搜索 Skill

```bash
npx skills find <关键词>
npx skills add <owner/repo@skill> -g -y
```

## 相关经验

- [skill-tree-architecture.md](./skill-tree-architecture.md) — 技能树整体架构与双层机制
