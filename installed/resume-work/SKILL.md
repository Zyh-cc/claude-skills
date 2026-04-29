---
name: resume-work
description: Use when the user says "继续", "继续工作", "继续上次", "接着做", "新会话", "上次做到哪了", "从上次开始", or starts a new session on an existing project. Fetches latest progress from GitHub and reads only the 已做工作 section to resume context efficiently.
---

# 继续工作：最小化启动流程

## 必做（两步，不多读）

**第一步：拉取最新进度，更新本地文件**

```bash
gh api repos/Zyh-cc/AeroGround-Dataset/contents/docs/%E9%A1%B9%E7%9B%AE%E6%80%BB%E8%BF%9B%E5%B1%95.md \
  --jq '.content' | base64 -d > AeroGround-Dataset/docs/项目总进展.md
```

> 文件名为中文，在 `gh api` 中必须 URL 编码，否则返回 404。  
> `base64 -d` 需要 Git Bash；当前用户环境已配置 Git Bash，可直接使用。  
> 如果当前目录已是 AeroGround-Dataset，路径改为 `docs/项目总进展.md`。

**第二步：只读"已做工作"节**

```bash
# 定位节的起始行号（输出格式：57:## 已做工作）
grep -n "^## 已做工作" AeroGround-Dataset/docs/项目总进展.md
```

拿到行号 N 后，用 **Read 工具**读取该节到末尾：

```
file_path: AeroGround-Dataset/docs/项目总进展.md   ← 或绝对路径
offset:    N      ← grep 输出的行号（1-based，直接用）
limit:     9999
```

> ❌ 不要 `tail -N`（倒数行数）：文件增长后会落在规划章节而非已做工作  
> ❌ 不要读整个文件：只需"已做工作"节之后的内容

MEMORY.md 已在上下文里，无需重复读。

---

## 不要做

- ❌ 读整个 progress.md（太长，末尾就够）
- ❌ 读 src/README.md、annotation/README.md 等文档（任务明确再按需读）
- ❌ 读本次对话里已出现过的文件
- ❌ "理解背景"式地读一堆相关文件

---

## 判断原则

读任何文件前先问：**"读了这个，我能做什么决策？"**  
答不上来 → 不读，先问用户。

---

## 启动后

- 用户已说明任务 → 直接开始，不汇报"我已了解进度"
- 用户未说明任务 → 直接问"今天做什么？"

---

## 异常处理

| 情况 | 处理方式 |
|------|---------|
| `gh api` 返回 404 | 检查 URL 编码是否正确；或直接问用户：进度文件路径是否变更？ |
| `项目总进展.md` 找不到"已做工作"节 | 读全文末尾 50 行，找最新条目 |
| `base64 -d` 报错（非 Git Bash 环境） | PowerShell 替代：`[System.Convert]::FromBase64String(...)` |
