---
name: resume-work
description: Use when the user says "继续", "继续工作", "继续上次", "接着做", "新会话", "上次做到哪了", "从上次开始", or starts a new session on an existing project
---

# 继续工作：最小化启动流程

## 必做（两步，不多读）

**第一步：拉取最新进度**
```bash
gh api repos/Zyh-cc/AeroGround-Dataset/contents/docs/progress.md \
  --jq '.content' | base64 -d > AeroGround-Dataset/docs/progress.md
```

**第二步：只读"已做工作"节**
```bash
# 先定位节的起始行号
gh api repos/Zyh-cc/AeroGround-Dataset/contents/docs/progress.md \
  --jq '.content' | base64 -d | grep -n "^## 已做工作"
# 再用 Read 工具 + offset 从该行读到文件末尾
# ❌ 不要用 tail -N，文件增长后 tail 会落在规划章节而非已做工作
```

MEMORY.md 已经在上下文里，不需要再读。

> **注意**：`base64 -d` 需要 Git Bash 或 WSL，PowerShell 中应改为 `[System.Convert]::FromBase64String(...)` 或直接用 Read 工具读取 API 返回的 `content` 字段手动解码。当前用户环境已配置 Git Bash，命令可直接使用。

---

## 不要做

- ❌ 读整个 progress.md（太长，末尾就够）
- ❌ 读 src/README.md、annotation/README.md 等文档（任务明确再按需读）
- ❌ 读刚才对话里已经出现过的文件
- ❌ "理解背景"式地读一堆相关文件

---

## 判断原则

读任何文件前先问：**"读了这个，我能做什么决策？"**
答不上来 → 不读，先问用户。

---

## 启动后

直接问用户今天做什么，或者如果用户已经说了任务，直接开始。
不需要先汇报"我已了解当前进度"——做就行了。
