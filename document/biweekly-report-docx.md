---
name: biweekly-report-docx
description: 为张天承生成两周总结 .docx 周报，格式完全对齐历史报告（黑体标题/宋体正文/删除线标记已完成任务）
version: 1.0.0
created: 2026-04-12
---

# 两周总结 .docx 生成技能

## 适用场景

用户说"写周报"、"生成两周总结"、"两周工作总结"时使用。

---

## 报告格式规范

文件命名：`张天承_YYYYMMDD_两周总结.docx`，保存至 `E:\清河\大学\科研\蒲自源\周报（2weeks）\`

### 页面设置

- 纸张：A4（11906 × 16838 DXA）
- 页边距：上下 1440，左右 1800（匹配历史报告）

### 段落层级

| 层级 | 字体（西文） | 字体（中文） | 字号(half-pt) | 行距 | 样式 |
|------|------------|------------|--------------|------|------|
| 标题/一级标题 | Times New Roman | 黑体 | 32 | 默认 | 无粗体 |
| 前期计划条目 ①②③ | 宋体 | 宋体 | 24 | 360(1.5x) | 完成→加删除线；未完成→正常 |
| 工作小标题 （1）（2） | Times New Roman | 宋体 | 28 | 360 | bold |
| 正文段落 | Times New Roman | 宋体 | 24 | 360 | 首行加 `\t` 缩进 |

### 文档结构

```
张天承 YYYYMMDD 两周总结          ← title()
一、工作进展                       ← sectionHead()
①上期计划项（已完成，加删除线）      ← planItem(text, strike=true)
②上期计划项（进行中，无删除线）      ← planItem(text, strike=false)
[空行]
（1）工作内容小标题                 ← subTitle()
    正文段落...                    ← body()
（2）...
[空行]
二、工作计划                       ← sectionHead()
①下期计划项                       ← planItem()
②...
```

---

## 生成方式

使用 `docx` npm 包（已全局安装：`C:\Users\13613\AppData\Roaming\npm\node_modules\docx`）。

**必须用环境变量指定 NODE_PATH 才能 require('docx')：**

```bash
NODE_PATH="C:\Users\13613\AppData\Roaming\npm\node_modules" node gen_report.js
```

直接 `node gen_report.js` 会报 `Cannot find module 'docx'`，即使 `npm install -g docx` 已完成。

### 核心代码模板

```javascript
const { Document, Packer, Paragraph, TextRun } = require('docx');
const fs = require('fs');

const fontBody = { ascii: "Times New Roman", eastAsia: "宋体", hAnsi: "Times New Roman", cs: "Times New Roman" };
const fontHeading = { ascii: "Times New Roman", eastAsia: "黑体", hAnsi: "Times New Roman", cs: "Times New Roman" };
const spacing15 = { line: 360, rule: "auto" };

function title(text) {
  return new Paragraph({
    children: [new TextRun({ text, font: fontHeading, size: 32, bold: false })],
  });
}

function sectionHead(text) {
  return new Paragraph({
    children: [new TextRun({ text, font: fontHeading, size: 32 })],
  });
}

function planItem(text, strike = false) {
  return new Paragraph({
    spacing: spacing15,
    children: [new TextRun({ text, font: { ascii: "宋体", eastAsia: "宋体", hAnsi: "宋体", cs: "宋体" }, size: 24, strike })],
  });
}

function subTitle(text) {
  return new Paragraph({
    spacing: spacing15,
    children: [new TextRun({ text, font: fontBody, size: 28, bold: true })],
  });
}

function body(text) {
  return new Paragraph({
    spacing: spacing15,
    children: [
      new TextRun({ text: "\t", font: fontBody, size: 24 }),
      new TextRun({ text, font: fontBody, size: 24 }),
    ],
  });
}

// 含粗体片段的正文：segments = [[text, bold], ...]
function bodyMixed(segments) {
  const runs = [new TextRun({ text: "\t", font: fontBody, size: 24 })];
  for (const [t, bold] of segments) {
    runs.push(new TextRun({ text: t, font: fontBody, size: 24, bold: !!bold }));
  }
  return new Paragraph({ spacing: spacing15, children: runs });
}

function emptyLine() {
  return new Paragraph({ spacing: spacing15, children: [new TextRun({ text: "", size: 24 })] });
}

const doc = new Document({
  sections: [{
    properties: {
      page: {
        size: { width: 11906, height: 16838 },
        margin: { top: 1440, right: 1800, bottom: 1440, left: 1800 },
      }
    },
    children: [
      title("张天承 20260412 两周总结"),
      sectionHead("一、工作进展"),
      // ... 内容 ...
      sectionHead("二、工作计划"),
      // ... 计划 ...
    ]
  }]
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync("E:\\清河\\大学\\科研\\蒲自源\\周报（2weeks）\\张天承_20260412_两周总结.docx", buf);
  console.log("Done");
});
```

---

## 已知 Bug 与注意事项

### 1. `Cannot find module 'docx'`（最常见）

`npm install -g docx` 安装到全局 `node_modules` 后，普通 `node script.js` 无法找到。
**必须设置 NODE_PATH：**
```bash
NODE_PATH="C:\Users\13613\AppData\Roaming\npm\node_modules" node script.js
```

### 2. JS 字符串中含中文引号导致 SyntaxError

正文中出现 `"` `"` 等中文引号时，双引号字符串 `"..."` 会被误解析为字符串结束。
**解决方案：** 将含中文引号的字符串改用单引号包裹：
```javascript
body('这段文字包含"中文引号"，使用单引号包裹')
```

### 3. validate.py 报 GBK 编码错误

Windows 中文环境下，`validate.py` 以 GBK 解码 UTF-8 的 XML 内容会报错。
**这是验证脚本自身的编码问题，不影响 docx 文件本身。**
用 `unpack.py` 解压并直接用 `Read` 工具查看 XML 确认中文正常即可。

### 4. 历史报告读取

历史报告 `.docx` 需用 `unpack.py` 解压后用 Read 工具读 XML（`word/document.xml`），
直接用 bash Python 脚本提取文本会因终端 GBK/UTF-8 编码不匹配而乱码。

---

## 内容来源

| 内容 | 来源 |
|------|------|
| 前期计划完成情况 | 上期周报的"二、工作计划"节 |
| 工作进展详情 | `AeroGround-Dataset/docs/progress.md` 的"已做工作"节 + MUST project_must.md |
| 下期计划 | progress.md 的"工作计划/阶段一"当前步骤 |

读取历史报告判断前期计划完成情况时，优先读最近一期的 `二、工作计划`。
