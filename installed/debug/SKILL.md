---
name: debug
description: Use when starting any bug fix, debugging an error, or diagnosing unexpected behavior. Triggers on: "修这个bug", "报错了", "为什么不对", "debug", "不工作了", "fix this", "error", "exception", "traceback"
---

# 修 Bug 通用流程

## Step 1：读错误，定位症状

```
1. 完整读取错误信息（不要只看最后一行）
2. 找到 traceback 的最底层：哪一行代码触发了错误？
3. 一句话描述症状："在 X 行，因为 Y，出现了 Z"
```

如果没有报错但行为不对 → 先加 `print` / `logging.debug` 打出关键变量，确认数据在哪一步开始偏离预期。

---

## Step 2：找变化点（退化问题必做）

"之前好用，现在不行" → **先找改变了什么**，不要先猜原理。

```bash
git log --oneline <文件>        # 该文件最近改动
git show <hash>                  # 查看具体变更
git diff HEAD~1 HEAD             # 与上一个提交对比
```

没有 git → 问用户：最近改了什么？升级了哪个包？

---

## Step 3：验证根因假设

**动手前必须能说出：** "因为 X，所以出现了 Y"。"可能是 X"不够。

验证方法（按难度选最简单的）：
- 文档/`help(obj)` — 确认 API 行为
- 最小复现脚本 — 去掉无关代码，3行能复现就不写30行
- `print` 中间变量 — 确认数据流向

---

## Step 4：找同类问题

定位后立刻问：**这个问题还在哪里出现？**

```bash
grep -rn "same_pattern" src/       # 同一错误模式
grep -rn "old_name" src/           # 命名变更未同步
```

全部列出，一次修完，再提交。

---

## Step 5：提交前自检

- [ ] 根因完全消除（不是绕过）？
- [ ] 同类问题都修了？
- [ ] 新假设已验证（跑过一次）？

---

## 常见陷阱

| 陷阱 | 正确做法 |
|------|---------|
| 修完第一个症状就提交 | 先列出所有同类问题再提交 |
| 假设 API 行为 | `help()` / 文档验证后再写修复 |
| 修复不生效直接换方案 | 先搞清楚这次修复为什么没生效 |
| `x is None` 检查缓存 | 合法假值（0/False）会绕过，用 `not x` |
| 看到错误就改代码 | 先完整读 traceback 再动手 |
