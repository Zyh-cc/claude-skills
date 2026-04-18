---
领域: document
版本: v1.0
最后更新: 2026-04-18
适用工具: Claude Code
---

# 基于真实文献撰写与核查调研报告：防止虚构引用的完整流程

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-18 | 初始版本，来自03/04调研报告两轮完整核查经验 |

## 问题场景

为论文第二章"现有方法不足"或类似综述章节撰写调研报告时：
- 需要大量引用文献的具体数据、结论
- LLM生成的报告容易产生**看起来合理但原文不存在**的引用（尤其是量化数据和综述性结论）
- 直接用blockquote格式写引用，但引号内容是释义而非原文

本经验覆盖：撰写前的风险分级、核查工作流、常见失效模式、修复方法。

---

## 风险分级：哪类引用最容易出错

| 风险等级 | 引用类型 | 典型例子 | 核查优先级 |
|---------|---------|---------|-----------|
| 🔴 极高 | 精确数值（百分比、mAP、误差） | "遮挡率>50%"、"+14.36 3D mAP" | 必须核查 |
| 🔴 极高 | 综述论文的归纳性结论 | "No existing dataset enables..." | 必须核查，极易虚构 |
| 🟡 中 | 方法描述中的定性判断 | "impractical for roadside scenarios" | 应核查 |
| 🟡 中 | 跨段落合并引用（用`...`连接） | 两句来自不同段落 | 应核查每段是否真实 |
| 🟢 低 | 数据集基本属性 | 帧数、传感器类型 | 表格可信度高，抽查 |

**核心规律**：综述类文献（survey）是最高风险来源。Survey作者自己也在做归纳，LLM很容易生成"survey会说的话"但实际不在原文里。

---

## 解决方案

### 推荐方案：pdftotext + grep 精准核查

**前提**：安装 pdftotext（xpdf/poppler），Windows Git Bash 中可用。

```bash
# 基本格式
pdftotext "路径/论文.pdf" - | grep -i "关键词" -A 2 -B 2

# 参数说明
# -    输出到 stdout，不写临时文件
# -i   忽略大小写
# -A 2 匹配行后2行
# -B 2 匹配行前2行
```

**核查步骤**：

1. **提取关键词**：从报告引用中选取最独特的2-3个词（避免高频词）
   - ✅ 好关键词："substantial overlaps"、"anti-occlusion perception"
   - ❌ 差关键词："occlusion"、"dataset"（过于常见）

2. **运行搜索**，看是否命中：
   ```bash
   pdftotext "paper.pdf" - | grep -i "impractical.*roadside\|roadside.*impractical" -A 3 -B 1
   ```

3. **比对原文与报告引用**：
   - 数值完全一致 → ✅ 确认
   - 跨段落合并但各部分准确 → ✅ 可接受（需注明`...`）
   - 找不到对应文本 → ❌ 删除直引，改为作者论述

4. **找不到时扩大搜索范围**：
   ```bash
   # 搜索论文所有关于该话题的讨论，判断是否有近似表述
   pdftotext "paper.pdf" - | grep -i "challeng\|limitation\|gap" -A 5 | head -100
   ```

### 备选方案：WebFetch arxiv HTML（需网络）

对于 arxiv 论文，访问 HTML 版本可直接 Ctrl+F：
```
https://arxiv.org/html/2410.11008
```
适合没有本地 PDF 的情况。但 arxiv 网络访问可能被封，需在 settings.json 中设置：
```json
{ "skipWebFetchPreflight": true }
```

---

## 撰写阶段：防患于未然

撰写时主动降低虚构风险：

**DO：**
- 每条直引附上原文定位（"摘要第2段"、"Table 3注释"）
- 量化数据明确注明表格行列（"Table II, V2I-Calib行, mRTE@1m列"）
- 综述性结论用作者自己的论述，不用blockquote格式直引
- 跨段落合并时用`...`并注明来源段落

**DON'T：**
- 直接生成带blockquote的引用而不核查
- 对综述论文使用直引格式（综述结论往往是释义而非原文）
- 用"某文献证明了X"而不确认X是否真的在文中

---

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 综述论文引用（arXiv:2404.14022）中"No existing dataset enables fair comparison..."无法核实 | 这是LLM生成的"综述该说的话"，实际原文讨论的是domain shift和sensor setup，没有这个具体表述 | 删除blockquote，改为作者论述 + 引用该综述的实际观点 |
| V2I-Calib++的0.5m/0.5°数值在论文前8页找不到 | 该数值在论文第9页 Table III 正文段落，不在前几页的摘要/介绍中 | 读更多页；对实验数据类引用，重点查实验章节而非前言 |
| Griffin评价AGC-Drive"lacks tracking IDs"，最初误判为来自Table 1而非正文 | 实际上正文第2页就有这句话，是先入为主地认为是表格数据 | 先用grep搜prose，再查table |
| 跨段落合并引用（RLCFormer）：两段话分别来自不同段落 | 用`...`合并是可接受的，但需确认两段话各自都在原文 | 分别用各段的独特关键词分别搜索确认 |
| pdftotext提取短综述（4页会议论文）只有299行 | 论文本身很短，全文提取是准确的，短不代表提取失败 | 用wc -l确认行数；行数少时直接查全文 |

---

## 核查完成后的处理规则

| 核查结果 | 处理方式 |
|---------|---------|
| ✅ 直引完全匹配 | 保留blockquote，可注明页码/章节 |
| ✅ 合理截断（`...`且各部分均准确） | 保留blockquote |
| ⚠️ 找不到直引，但论文有相近意思 | 删除blockquote，改为："X et al. 指出……（[引用]）" |
| ❌ 完全找不到对应内容 | 删除整条引用；若论点仍需支撑，改用其他文献或作者自述 |

---

## 相关经验

- [academic-writing-style-zh.md](academic-writing-style-zh.md) — 中文学术写作规范，与本经验配合使用
- [task-driven-thesis-framework.md](task-driven-thesis-framework.md) — 论文整体框架设计，调研报告的上游任务
- [china-policy-search.md](china-policy-search.md) — 标准文件查找（调研报告中标准类引用的专项方法）
