---
领域: skills-management
版本: v1.0
最后更新: 2026-03-30
适用工具: Claude Code
---

# Skill 安装与热加载问题

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-30 | 初始版本 |

## 问题场景

在当前 session 中用 `npx skills add` 安装新 skill 后，用 `Skill` 工具调用时提示「Unknown skill」。

## 解决方案

### 推荐方案：重启 session

安装 skill 后关闭当前 Claude Code session，重新打开即可正常调用。

### 备选方案：手动读取 skill 文件

```bash
# 找到 skill 安装位置
ls ~/.agents/skills/

# 读取 SKILL.md，按其中的命令手动操作
cat ~/.agents/skills/<skill-name>/SKILL.md
```

然后直接用 Bash 执行 skill 文件中描述的命令，绕过 Skill 工具。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| Skill 工具报 Unknown skill | session 启动时 skill 列表已固定，新安装不会热加载 | 重启 session |
| 找不到 skill 安装路径 | 默认安装在 `~/.agents/skills/` | 用 `ls ~/.agents/skills/` 查找 |

## 搜索 Skill

```bash
npx skills find <关键词>
npx skills add <owner/repo@skill> -g -y
```

## 相关经验

- [browser/agent-browser.md](../browser/agent-browser.md) — agent-browser skill 的使用
