---
name: post-code-review
description: Use when a new script has been written or significant code changes (>50 lines) have been made, before committing — to catch variable scope errors, cross-file integration mismatches, and naming convention gaps
---

## 触发条件

写完新脚本 or 修改超过 50 行后，**提交前**必须执行本流程。

例外（可跳过）：只改注释、改动 <10 行且无跨文件交互、纯 typo 修复。

---

## 执行步骤

### 第一轮：用 superpowers:code-reviewer 发现 bug

调用 `superpowers:code-reviewer` agent，提供以下上下文：

```
请校核 <文件路径>：
- 功能：<这个脚本/改动做什么>
- 与哪些文件交互：读/写 <文件列表>，调用 <函数列表>
- 特别关注：<命名变更 / 格式变更 / 跨脚本字段传递>
请找出逻辑错误、变量作用域问题、与外部文件的集成不一致。
```

重点让 reviewer 检查：
1. **变量作用域**：每个函数内变量先定义后使用
2. **跨脚本字段一致性**：A 脚本写入的字段，B 脚本读取时是否同名同结构
3. **命名约定遗漏**：若有命名规则变更，所有引用点（glob、格式字符串、硬编码路径）是否全部更新
4. **初始化完整性**：dict 初始化是否包含所有后续可能访问的字段

### 第二轮：确认修复（若第一轮发现 ≥2 个 bug 必做）

```
已修复：[列出修复内容]
请确认修复正确，并检查是否引入新问题。
```

---

## 典型 bug 模式（高频）

| 模式 | 示例 |
|------|------|
| 变量先用后定义 | `warns.append(...)` 在 `warns = []` 之前 |
| 跨脚本索引错位 | A 脚本存 `bbox_idx`（置信度排序），B 脚本当行号用 |
| glob 与命名不匹配 | 命名改为 `img_XXXX_N.json`，glob 还是 `review_log_*.json` |
| dict 字段初始化不全 | 新增字段后只更新了部分初始化点 |
