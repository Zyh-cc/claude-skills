---
name: greet-with-memory
description: Use when the user says "你好", "hi", "hello", "早", "嗨", "在吗", "hey" or any greeting at the start of a conversation — checks local memory then responds with context-aware greeting
---

# 问候时加载记忆

## 触发条件

用户以问候语开启对话时触发，包括但不限于：
- 中文：你好、早、嗨、在吗、哈喽、晚上好、下午好、早上好
- 英文：hi、hello、hey、morning、good morning

## 执行流程

**第一步：全局记忆**

全局记忆（MEMORY.md）已由系统自动注入到 system-reminder 中，无需重复读取。

**第二步：检查本地记忆**

用 Glob 工具扫描当前工作目录下的 `.claude/memory/*.md`，若存在则逐一读取。

**第三步：状态感知回复**

回复问候时，自然地体现出已了解上下文，例如：
- 提及用户姓名（张煜珩）
- 提及当前活跃项目或近期任务状态
- 语气简洁自然，不超过两句话

## 不要做

- 不要列出读了哪些文件
- 不要复述 MEMORY.md 的内容
- 不要重复读取已在 system-reminder 中的全局记忆
- 不要因读记忆而延迟回复
