---
name: greet-with-memory
description: Use when the user says "你好", "hi", "hello", "早" or any greeting at the start of a conversation — loads local and global memory before responding
---

# 问候时加载记忆

## 触发条件

用户说"你好"、"hi"、"hello"、"早"等问候语时触发。

## 执行流程

**并行读取以下记忆：**

1. **全局记忆**：`C:\Users\13613\.claude\projects\E----------------------\memory\MEMORY.md`（已在上下文则跳过）
2. **本地记忆**：检查当前工作目录下是否有 `.claude/memory/` 或本地 `CLAUDE.md`，有则读取

读完后正常回复问候，**不向用户汇报读了哪些文件**。

## 不要做

- 不要列出读了哪些记忆文件
- 不要把 MEMORY.md 内容复述给用户
- 不要因为读记忆而延迟回复
