---
name: literature-based-report-verification
description: Use when user needs to verify research report citations against source papers, check if quoted text actually exists in literature, or fix fabricated/misattributed quotes in academic reports. Trigger words: 核查引用、查文献原文、检查虚构引用、verify citation、fix fabricated quote
---

## 启动前：确认输入材料

**首先询问用户提供：**
1. 待核查的报告文件（或粘贴引用文本）
2. 对应原文 PDF 的本地路径（每条引用对应的论文）

若用户只提供报告文本、未提供 PDF 路径，先列出所有引用条目，询问用户补充路径后再开始核查。

---

## 第一步：风险分级（决定核查优先级）

| 风险 | 类型 | 处理 |
|------|------|------|
| 🔴 极高 | 综述论文的归纳性结论（"No existing X..."） | 必须核查，最易虚构 |
| 🔴 极高 | 精确数值（百分比、mAP、误差阈值） | 必须核查 |
| 🟡 中 | 定性判断、方法描述 | 应核查 |
| 🟡 中 | 跨段落合并引用（用`...`连接） | 分别核查两段 |
| 🟢 低 | 数据集基本属性（帧数、传感器类型） | 抽查即可 |

**输出：** 列出"极高风险引用 N 条、中风险 M 条、低风险 K 条"，告知用户将按风险从高到低逐条核查。

---

## 第二步：逐条核查（pdftotext + grep）

### 基本命令

```bash
# 需安装 xpdf/poppler（Windows: choco install xpdf-utils 或 scoop install poppler）
pdftotext "路径/论文.pdf" - | grep -i "关键词" -A 2 -B 2
# - 输出到stdout；-i 忽略大小写；-A/-B 显示上下文行数
```

### 关键词选取原则
- ✅ 好：选引用中最独特的 2-3 个词，如 `"substantial overlaps"`、`"anti-occlusion perception"`
- ❌ 差：避免高频词如 `"occlusion"`、`"dataset"`

### 找不到时的扩大搜索（fallback）

```bash
# 1. 确认PDF可正常提取（行数极少说明是扫描件）
pdftotext "paper.pdf" - | wc -l

# 2. 扫描件 fallback：用 Claude 的 Read 工具直接读取 PDF（支持扫描件 OCR）
# 3. 若可提取，搜索相关语境段落
pdftotext "paper.pdf" - | grep -i "challeng\|limitation\|gap" -A 5 | head -60
```

---

## 第三步：判定 + 处理（每条引用输出一行结论）

| 核查结果 | 处理方式 |
|---------|---------|
| ✅ 直引完全匹配 | 保留 blockquote |
| ✅ 合理截断（`...`且各部分均准确） | 保留 blockquote |
| ⚠️ 找不到直引，但论文有相近意思 | 删除引号，改为："X et al. 指出……（[引用]）" |
| ❌ 完全找不到对应内容 | 删除整条；若论点仍需支撑，改用其他文献或作者自述 |

---

## 第四步：确认 + 输出修改摘要

**在批量修改前，先向用户输出核查汇总表：**

```
| # | 引用文本（前30字） | 来源论文 | 判定 | 建议操作 |
|---|-----------------|---------|------|---------|
| 1 | "No existing..."  | Chen2023 | ❌虚构 | 删除 |
| 2 | "mAP达到89.3%"    | Liu2022  | ✅匹配 | 保留 |
```

**询问用户："以上修改方案是否确认？确认后我将直接修改报告文本。"**

收到确认后再执行修改，并输出修改后的完整文本段落。

---

## 踩坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 综述论文引用查不到 | LLM生成"综述该说的话"，实际原文没有 | 综述类引用一律先搜索验证，不信任直引格式 |
| 数值在论文后半段 | 前8页是摘要/介绍，实验数据在实验章节 | 对量化引用重点查实验章节 |
| pdftotext只提取到几百行 | 短会议论文或PDF有提取问题 | `wc -l` 确认行数；行数少时用 Read 工具读PDF |
| 跨段落合并引用被误判虚构 | 两句分别来自不同段落，各自准确 | 用各段独特词分别搜索确认 |
| Windows路径含中文或空格 | pdftotext 解析失败 | 路径加双引号；中文路径改用 Read 工具 |

---

## 写作阶段防虚构（前置提醒）

**DO：** 综述性结论用作者论述格式而非 blockquote；量化数据附表格定位（"Table II, V2I-Calib行"）

**DON'T：** 对综述论文使用直引格式；直接生成带 blockquote 的引用不核查
