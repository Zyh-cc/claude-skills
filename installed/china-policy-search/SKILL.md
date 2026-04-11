---
name: china-policy-search
description: Search Chinese government policy documents for academic paper background sections. Use this whenever writing a Chinese thesis or journal paper that needs policy citations — Five-Year Plans, State Council documents, ministry notices. Trigger on any request like "找政策文件", "政策背景", "引用法规", or "写绪论政策段落".
---

## Core principle: search top-down by hierarchy

```
Level 1 (highest): NPC-approved Five-Year Plan (全国人大批准的五年规划纲要)
Level 2: CPC Central Committee documents
Level 3: State Council orders (国发/国办发〔〕号)
Level 4: Multi-ministry joint documents (工信部联〔〕号)
Level 5: Single ministry documents
Level 6: Provincial/local documents
```

## Step 1: Identify the current Five-Year Plan period

```
Current date → Plan:
  2021-2025 → 十四五
  2026-2030 → 十五五 (current)
  2031-2035 → 十六五
```

Search template: `{topic} {plan-name}规划纲要 {current-year}`

## Step 2: Four search queries that cover most topics

1. `{主题} 十五五规划纲要` — top-level plan
2. `{主题} 政府工作报告 {current-year}` — latest government statement
3. `{主题} 国务院令 OR 国务院文件 文号` — administrative regulations with document number
4. `{主题} 工信部 OR 发改委 实施方案 文号` — ministry implementation documents

## Citation formats (Chinese thesis standard)

| Level | Format |
|-------|--------|
| Five-Year Plan | 国民经济和社会发展第十五个五年规划纲要[Z]. 北京: 人民出版社, 2026. |
| State Council order | 国务院. 文件名: 国令第N号[A]. 年份. |
| Multi-ministry doc | 工业和信息化部等. 文件名: 文号[A]. 年份. |

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Missing the Five-Year Plan | Searched "政策文件" not "规划纲要" | Always start with 五年规划 |
| Results stuck in 2023-2024 | Hard-coded year in query | Use current year or omit year |
| Found ministry doc, missed NPC-level | Started mid-hierarchy | Always check if topic is in Five-Year Plan first |
| Can't find with English terms | Chinese policy docs are Chinese-first | Use Chinese keywords; primary source: gov.cn / npc.gov.cn |
