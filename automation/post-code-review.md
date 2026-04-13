---
领域: automation
版本: v1.0
最后更新: 2026-04-13
适用工具: Claude Code
---

# 生成代码后自动校核：用 superpowers:code-reviewer 两轮审查，拦截集成 bug

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-13 | 初始版本，提炼自 apply_review.py 的校核经验 |

## 问题场景

写完一个新脚本或对已有脚本做较大改动（>50行），代码本身逻辑自洽，但存在三类隐藏 bug：

1. **变量作用域错误**：变量在引用之前才定义（如 `warns`/`warnings` 命名混淆）
2. **集成不一致**：脚本 A 和脚本 B 对同一字段的理解不同（如 `bbox_idx` 在 detail JSON 中是置信度排序序号，在 KITTI .txt 中是行号）
3. **命名约定遗漏**：设计阶段更改了命名规则，但代码中某处仍引用旧命名（如 glob 用 `review_log_*.json` 但新文件命名为 `img_XXXX_N.json`）

这类 bug 在单独看代码时很难发现，只有结合上下文和多文件交叉比对才能暴露。

## 解决方案

### 推荐方案：superpowers:code-reviewer 两轮审查

**触发时机**：写完新脚本 or 修改超过 50 行的改动后，**提交前**必做。

**第一轮：发现 bug**

向 `superpowers:code-reviewer` 提供：
- 代码目标和设计意图（"这个脚本做什么"）
- 与哪些文件/函数有交互（读/写哪些文件，调用哪些函数）
- 特别关注点（如果有命名变更、格式变更等）

示例 prompt：
```
请校核 src/annotation/apply_review.py：
- 功能：根据 review_log JSON 对 KITTI .txt 文件做 FP 删除 / FN 追加
- 交互：读 ANNOT_DIR/*.txt，读 DETAIL_DIR/*_detail.json，读 REVIEW_LOG_DIR/*.json
- 注意：FP 匹配用坐标而非 bbox_idx（detail JSON 按置信度排序，与 .txt 行号不对应）
- 注意：review log 新命名为 img_XXXX_N.json，GUI glob 需兼容
请找出逻辑错误、变量作用域问题、与外部文件的集成不一致。
```

**第二轮：确认修复**

修完第一轮发现的 bug 后，再做一轮：
```
已修复以下问题：[列出修复内容]
请确认修复正确，并检查是否引入新问题。
```

**判断是否需要两轮**：若第一轮发现了 2 个及以上 bug，必须做第二轮。

### 什么情况下可以跳过

- 只改注释、文档字符串、日志格式
- 改动 < 10 行且无跨文件交互
- 单纯修 typo 或常量值

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| `warnings` 变量在 `warns =[]` 定义前被引用 | 函数体内变量命名和引用不在同一处 | 审查时专门检查每个函数内的变量先定义后使用 |
| `bbox_idx` 传递给 FP 匹配却指向错误行 | detail JSON 按置信度降序排列，KITTI .txt 按处理顺序，两者索引不同 | 提供 reviewer "哪些字段跨脚本传递" 的上下文 |
| GUI glob `review_log_*.json` 不匹配 `img_0013_1.json` | 命名规范在设计时更改了，但 glob 字符串漏改 | 明确告知 reviewer 命名约定变更点 |
| `_kitti_to_cache_bboxes` 缺少 `size_score` 等字段 | 初始化只写了必要字段，后来新增字段未补全 | 检查所有 `dict(...)` 初始化是否与其他地方的同类 dict 结构一致 |

## 相关经验

- [debug.md](../debugging/debug.md) — 通用 bug 修复五步流程，校核发现 bug 后按此流程处理
- [open3d-interactive-review.md](../data-processing/open3d-interactive-review.md) — 本次 apply_review.py 的上游工具，两者集成 bug 典型案例
