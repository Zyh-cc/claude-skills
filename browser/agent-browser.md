---
领域: browser
版本: v1.0
最后更新: 2026-03-30
适用工具: Claude Code
---

# agent-browser 浏览器自动化基本用法

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-30 | 初始版本 |

## 问题场景

需要与动态渲染的网页交互：点击按钮、填写表单、抓取 JS 渲染内容。

## 安装

```bash
npx skills add vercel-labs/agent-browser@agent-browser -g -y
npm i -g agent-browser
agent-browser install  # 下载 Chrome，约 180MB
```

## 解决方案

### 基本工作流

```bash
# 1. 打开页面并等待加载完成
agent-browser open https://example.com && agent-browser wait --load networkidle

# 2. 获取页面元素快照（带 ref 编号）
agent-browser snapshot -i

# 3. 根据 ref 与元素交互
agent-browser click @e1
agent-browser fill @e2 "输入内容"

# 4. 重新获取快照确认结果
agent-browser snapshot -i
```

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| snapshot 中找不到下载链接 | GitHub Assets 链接未以 link 形式暴露 | 改用 gh CLI 获取 URL |
| session 内安装后无法用 Skill 工具调用 | skill 列表在 session 启动时已固定 | 重启 session 或手动读取 skill 文件 |

## 相关经验

- [download/github-release.md](../download/github-release.md) — 配合 gh CLI 获取下载链接
- [skills-management/skill-lifecycle.md](../skills-management/skill-lifecycle.md) — Skill 热加载问题
