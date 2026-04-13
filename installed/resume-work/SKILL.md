---
name: resume-work
description: Use when the user says "继续", "继续工作", "继续上次", "接着做", or starts a new session on an existing project
---

# 继续工作：最小化启动流程

## 必做（两步，不多读）

**第一步：拉取最新进度**
```bash
gh api repos/Zyh-cc/AeroGround-Dataset/contents/docs/progress.md \
  --jq '.content' | base64 -d > AeroGround-Dataset/docs/progress.md
```

**第二步：只读末尾"已做工作"节**
```bash
# 不要全文读，只读最后 40 行左右
# 用 Read 工具加 offset 定位到"已做工作"节
```

MEMORY.md 已经在上下文里，不需要再读。

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
