---
name: biweekly-report
description: Use when the user asks to write, generate, or create a biweekly summary report (两周总结/周报) for 张天承. Triggers on phrases like 写周报, 两周总结, 两周报告, biweekly report, work summary.
---

# 张天承两周总结生成

为导师蒲自源教授生成两周工作总结 .docx 文件，格式完全对齐历史报告。

## 生成流程

1. **读取内容来源**（并行）
   - `AeroGround-Dataset/docs/progress.md` → 最近两周"已做工作"节
   - 上期周报"二、工作计划"节 → 确认哪些已完成（加删除线）、哪些进行中
   - `memory/project_must.md` → MUST 系统最新状态

2. **[确认点]** 展示本期内容摘要（工作进展要点 + 工作计划3条）给用户确认，再继续

3. **写 JS 脚本**，保存到周报目录，用 `NODE_PATH` 运行

4. **验证**：unpack.py 解压 + Read 工具读 XML 确认中文正常

5. **清理**：删除 JS 脚本和临时 unpacked_* 目录

---

## 文件规范

- **保存路径**：`E:\清河\大学\科研\蒲自源\周报（2weeks）\`
- **命名**：`张天承_YYYYMMDD_两周总结.docx`（日期取最近的周一，不一定是生成当天）

---

## 写作风格要求（强制）

从用户修改记录归纳，每次生成必须遵守：

| 规则 | 错误示例 | 正确示例 |
|------|---------|---------|
| 措辞保守 | "联调完成""系统就绪" | "初步调试完成""初步验证通过" |
| 不写技术文件名 | `las_to_frames.py` | `las文件切帧程序` |
| 小标题用纯中文 | `MUST路侧采集系统联调完成` | `MUST路侧采集系统初步调试` |
| 不写具体日期 | "于 2026-04-09 验证通过" | 直接描述结果，不加日期 |
| 不写质检/统计细节 | "异常帧 23 帧，占比 0.56%" | 合并入主体段落一句带过或省略 |
| 不写论文进展 | 单独列"论文第一章草稿完成" | 不出现在周报中 |
| 工作计划简洁 | 列 4-5 条 | ①②③ 三条即可 |

---

## 页面设置

```javascript
properties: {
  page: {
    size: { width: 11906, height: 16838 },       // A4
    margin: { top: 1440, right: 1800, bottom: 1440, left: 1800 },
  }
}
```

---

## 段落层级与字体

```javascript
const fontBody    = { ascii: "Times New Roman", eastAsia: "宋体",  hAnsi: "Times New Roman", cs: "Times New Roman" };
const fontHeading = { ascii: "Times New Roman", eastAsia: "黑体",  hAnsi: "Times New Roman", cs: "Times New Roman" };
const spacing15   = { line: 360, rule: "auto" };  // 1.5倍行距
```

| 层级 | 函数 | 字号(half-pt) | 字体 | 特殊 |
|------|------|--------------|------|------|
| 文档标题 / 一、二、 | `title()` / `sectionHead()` | 32 | 黑体 | — |
| 前期计划 ①②③ | `planItem(text, strike)` | 24 | 宋体 | 完成→`strike:true` |
| 工作小标题（1）（2） | `subTitle()` | 28 | 宋体 | bold |
| 正文段落 | `body()` | 24 | 宋体 | 首行加 `\t` |
| 含粗体片段 | `bodyMixed([[text,bold]])` | 24 | 宋体 | — |

---

## 完整代码模板

```javascript
const { Document, Packer, Paragraph, TextRun } = require('docx');
const fs = require('fs');

const fontBody    = { ascii: "Times New Roman", eastAsia: "宋体",  hAnsi: "Times New Roman", cs: "Times New Roman" };
const fontHeading = { ascii: "Times New Roman", eastAsia: "黑体",  hAnsi: "Times New Roman", cs: "Times New Roman" };
const spacing15   = { line: 360, rule: "auto" };

const title      = t => new Paragraph({ spacing: spacing15, children: [new TextRun({ text: t, font: fontHeading, size: 32, bold: false })] });
const sectionHead= t => new Paragraph({ spacing: spacing15, children: [new TextRun({ text: t, font: fontHeading, size: 32 })] });
const planItem   = (t, strike=false) => new Paragraph({ spacing: spacing15,
  children: [new TextRun({ text: t, font: { ascii:"宋体", eastAsia:"宋体", hAnsi:"宋体", cs:"宋体" }, size: 24, strike })] });
const subTitle   = t => new Paragraph({ spacing: spacing15,
  children: [new TextRun({ text: t, font: fontBody, size: 28, bold: true })] });
const body       = t => new Paragraph({ spacing: spacing15,
  children: [new TextRun({ text: "\t", font: fontBody, size: 24 }), new TextRun({ text: t, font: fontBody, size: 24 })] });
const emptyLine  = () => new Paragraph({ spacing: spacing15, children: [new TextRun({ text: "", size: 24 })] });

const doc = new Document({
  sections: [{
    properties: { page: { size: { width: 11906, height: 16838 }, margin: { top:1440, right:1800, bottom:1440, left:1800 } } },
    children: [
      title("张天承 YYYYMMDD 两周总结"),
      sectionHead("一、工作进展"),
      planItem("①上期计划项（已完成）", true),
      planItem("②上期计划项（进行中）", false),
      emptyLine(),
      subTitle("（1）工作内容小标题"),
      body("正文段落，首行自动缩进..."),
      emptyLine(),
      sectionHead("二、工作计划"),
      planItem("①下期计划"),
      planItem("②下期计划"),
    ]
  }]
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync("E:\\清河\\大学\\科研\\蒲自源\\周报（2weeks）\\张天承_YYYYMMDD_两周总结.docx", buf);
  console.log("Done");
});
```

---

## 运行命令

```bash
# 必须设 NODE_PATH，否则报 Cannot find module 'docx'
NODE_PATH="C:\Users\13613\AppData\Roaming\npm\node_modules" node gen_report.js
```

---

## 已知 Bug

| Bug | 原因 | 解决 |
|-----|------|------|
| `Cannot find module 'docx'` | npm global 包不在默认 NODE_PATH | 加 `NODE_PATH=...` 环境变量 |
| SyntaxError: missing ) | 正文含中文引号 `"` `"` 被 JS 解析为字符串边界 | 把含中文引号的字符串改用单引号 `'...'` 包裹 |
| validate.py 报 GBK 乱码 | Windows 终端 GBK vs XML UTF-8 | 忽略，用 unpack.py + Read 工具验证 XML 即可 |
| bash 输出中文乱码 | Bash 工具走终端 GBK 编码 | 读 docx/XML 内容**只用 Read 工具**，不用 Python subprocess 打印 |

---

## 验证方式

```bash
python "C:\Users\13613\.claude\plugins\marketplaces\anthropic-agent-skills\skills\docx\scripts\office\unpack.py" output.docx unpacked_tmp
# 然后用 Read 工具读 unpacked_tmp\word\document.xml 确认中文正常
```

验证完毕后删除 JS 脚本和 unpacked_tmp 目录。
