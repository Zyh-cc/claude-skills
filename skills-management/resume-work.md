---
领域: skills-management
版本: v1.0
最后更新: 2026-04-13
适用工具: Claude Code
keywords: 继续, 继续工作, 继续上次, 接着做, resume, continue
---

# 继续工作：最小化启动，不过度读文件

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-13 | 初始版本，来自用户反馈：继续工作时消耗过多 token |

## 问题场景

新会话开始时用户说"继续"，Claude 倾向于读大量文件"理解背景"，
消耗大量 token，大部分内容其实已经在 MEMORY.md 或对话里。

## 解决方案

**只做两步：**

1. 拉取最新 progress.md：
```bash
gh api repos/Zyh-cc/AeroGround-Dataset/contents/docs/progress.md \
  --jq '.content' | base64 -d > AeroGround-Dataset/docs/progress.md
```

2. 只读末尾"已做工作"节（用 offset 定位，不读全文）。

MEMORY.md 已在上下文，不需要额外读。

## 不要做

- 读整个 progress.md
- 读 README / 文档类文件（除非任务明确需要）
- 读同一会话里已出现的文件
- "理解背景"式地读一堆相关文件

## 判断原则

读任何文件前先问：**"读了这个，我能做什么决策？"**
答不上来 → 不读，先问用户。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 读完一堆文件还是问用户"你想做什么" | 读文件没有减少歧义，只消耗 token | 不如直接问 |
| 读 progress.md 全文 | 惯性 | 用 offset 只读末尾节 |

## 相关经验

- [feedback_file_read_discipline.md](../memory/feedback_file_read_discipline.md) — 文件读取通用纪律
