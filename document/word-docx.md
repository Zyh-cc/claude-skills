---
领域: document
版本: v1.1
最后更新: 2026-03-30
适用工具: Claude Code
keywords: word, docx, xml, table, format, style, 文档, 排版, 表格, 标题, 格式, 报告, 论文
---

# Word (.docx) 文档编辑全流程

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-26 | 初始版本 |
| v1.1 | 2026-03-30 | 迁移至新格式，补充版本日志 |
| v1.2 | 2026-04-11 | 补充§零"只读内容"标准流程；根因：未查技能树导致重复踩 GBK 编码坑 |

## 零、只读内容（提取文本，不编辑）

**不要用 pandoc（本机未安装），不要 print 中文到 stdout（GBK 报错）。**

```bash
# 解包
PYTHON=/c/Users/13613/AppData/Local/Programs/Python/Python312/python.exe
SKILL_DIR="/c/Users/13613/.claude/plugins/marketplaces/anthropic-agent-skills/skills/docx"
$PYTHON "$SKILL_DIR/scripts/office/unpack.py" "E:/路径/文档.docx" C:/Temp/work_dir/

# 提取文本 → 写入文件（不能 print，Windows stdout 是 GBK）
$PYTHON -c "
import xml.etree.ElementTree as ET
tree = ET.parse('C:/Temp/work_dir/word/document.xml')
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
lines = []
for p in tree.getroot().findall('.//w:p', ns):
    text = ''.join(t.text or '' for t in p.findall('.//w:t', ns))
    if text.strip(): lines.append(text)
open('C:/Temp/output.txt', 'w', encoding='utf-8').write('\n'.join(lines))
"

# 用 Read 工具读取结果
# Read: C:/Temp/output.txt
```

---

## 一、工作流标准流程

```
unpack → 编辑 XML → pack → cp 到目标路径
```

### 完整命令模板

```bash
# 1. 解包
cd /c/Users/13613/.claude/plugins/marketplaces/anthropic-agent-skills/skills/docx
/c/Users/13613/AppData/Local/Programs/Python/Python312/python.exe \
  scripts/office/unpack.py "E:/路径/文档.docx" /tmp/work_dir/

# 2. 编辑 /tmp/work_dir/word/document.xml 或 styles.xml

# 3. 打包（Windows 下必须加 --validate false）
/c/Users/13613/AppData/Local/Programs/Python/Python312/python.exe \
  scripts/office/pack.py /tmp/work_dir/ /tmp/output.docx \
  --original "E:/路径/文档.docx" --validate false

# 4. 写回（避免权限报错，先写到 /tmp 再 cp）
cp /tmp/output.docx "E:/路径/文档.docx"
```

---

## 二、踩坑记录与解决方案

### ❶ Python 环境问题：系统 `python` 指向 Anaconda，缺少必要包

**报错**
```
ModuleNotFoundError: No module named 'defusedxml'
ModuleNotFoundError: No module named 'lxml'
```

**原因**
`python` 命令指向 Anaconda 环境，该环境没有 `defusedxml` / `lxml`。

**解决**
始终使用独立安装的 Python 完整路径：
```bash
/c/Users/13613/AppData/Local/Programs/Python/Python312/python.exe
```
如需安装缺失包：
```bash
/c/Users/13613/AppData/Local/Programs/Python/Python312/python.exe -m pip install defusedxml lxml
```

---

### ❷ Windows 编码问题：pack.py 校验器 GBK 报错

**报错**
```
'gbk' codec can't decode byte 0x... in position ...
```

**原因**
pack.py 内置 XML 校验器在 Windows 下以 GBK 编码读取 UTF-8 文件。

**解决**
打包时始终加 `--validate false` 跳过校验，对文档正确性无影响：
```bash
python scripts/office/pack.py ... --validate false
```

---

### ❸ 权限报错：docx 文件在 Word 中打开时无法写入

**报错**
```
PermissionError: [Errno 13] Permission denied: 'E:/.../.docx'
```

**原因**
Word 占用文件写锁。

**解决**
先写到 `/tmp/`，关闭 Word 后再 `cp`：
```bash
python scripts/office/pack.py ... /tmp/output.docx ...
cp /tmp/output.docx "E:/目标路径/文档.docx"
```

---

### ❹ styles.xml 元素顺序报错

**报错**
```
spacing not expected at this position
rPr not expected at this position
```

**原因**
对 table 类型的 style（如 `w:type="table"`）错误添加了 `<w:spacing>` 或 `<w:rPr>`，这些元素只属于 paragraph / character 类型的样式。

**解决**
修改脚本，限定只处理 `style_type in ('paragraph', 'character')` 的样式：
```python
style_type = style.get(w('type'), '')
if style_type not in ('paragraph', 'character'):
    continue
```

---

### ❺ Bash Heredoc 与复杂 Python 脚本的 EOF 错误

**报错**
```
bash: unexpected EOF while looking for matching `''
```

**原因**
Python 脚本中含有单引号、反斜杠等特殊字符，与 heredoc 分隔符冲突。

**解决**
有两种方式：
1. 用 `Write` 工具直接写文件（推荐），绕过 shell 转义
2. 用 `cat > /tmp/script.py << 'PYEOF' ... PYEOF`（注意 PYEOF 加引号禁止变量展开）

---

### ❻ `/tmp/` 路径在 bash 与 Windows Python 中不一致

**现象**
bash 中 `/tmp/report_v3/` 存在，但 Python 脚本用 `/tmp/report_v3/` 报 FileNotFoundError。

**原因**
- bash（Git Bash）：`/tmp/` = `C:\Users\13613\AppData\Local\Temp\`
- Windows Python：`/tmp/` 不识别，需要 Windows 格式路径

**解决**
Python 脚本中使用 Windows 原生路径：
```python
doc_path = r'C:\Users\13613\AppData\Local\Temp\report_v3\word\document.xml'
```
或用 `cygpath -w /tmp/xxx` 转换：
```bash
cygpath -w /tmp/report_v3   # 输出 C:\Users\13613\AppData\Local\Temp\report_v3
```

---

### ❼ Write 工具写入路径 vs bash `/tmp/` 路径

**现象**
用 `Write` 工具写 `/tmp/fix_v3.py`，但 bash `ls /tmp/fix_v3.py` 找不到。

**原因**
Write 工具和 bash 对 `/tmp/` 的映射不总是一致（取决于 Claude Code 内部路径处理）。

**解决**
优先用 `cat > /tmp/script.py << 'PYEOF'` 在 bash 中直接写文件，确保路径一致。

---

### ❽ MCP 配置问题：`claude mcp add` 报 git-bash 路径错误

**报错**
```
spawn git-bash ENOENT
```

**原因**
Claude Code 找不到 git-bash 可执行文件路径。

**解决**
在运行前设置环境变量：
```bash
export CLAUDE_CODE_GIT_BASH_PATH="D:\Git\bin\bash.exe"
```

---

### ❾ pandoc 生成文档 vs 用户手动排版的格式冲突

**现象**
pandoc 从 markdown 转换生成的 docx 使用 `SourceCode`、`Heading1`、`BodyText` 等样式 ID，用户在 Word 中手动排版后改为原生 Word 样式（直接在 run 上设置字体字号，无 pStyle）。

**教训**
**每次编辑文档前，必须先 unpack 读取当前 document.xml，确认实际使用的样式结构，不能假设沿用上次的格式。**

---

## 三、用户文档排版规范（悬索桥研讨报告定稿格式）

> 文件：`E:\清河\大学\学科\桥梁前沿\作业\悬索桥研讨报告.docx`

### 3.1 文档默认（docDefaults）

| 属性 | 值 |
|------|----|
| 中文字体（eastAsia） | 宋体 |
| 西文/数字字体（ascii/hAnsi） | Times New Roman |
| 字号 | 12pt（sz=24） |
| 行距 | 1.5倍（line=360，lineRule=auto） |

### 3.2 标题格式

> **重要**：标题不使用 Heading1/Heading2 等样式，直接在 `<w:rPr>` 中设置字体和字号。

| 层级 | 示例 | 字体（eastAsia+ascii+hAnsi） | 字号 | 行距 | 对齐 |
|------|------|-------------------------------|------|------|------|
| 文档大标题 | "悬索桥的工程逻辑…" | 黑体 | 18pt（sz=36） | line=300 | 居中 |
| 议题一级标题 | "2 议题一：…" | 黑体 | 16pt（sz=32） | line=300 | 左对齐 |
| 章节二级标题 | "一、引言"、"2.1 …" | 黑体 | 14pt（sz=28） | line=300 | 左对齐 |
| 标题颜色 | 所有层级 | — | — | — | 纯黑 #000000 |

### 3.3 正文段落

| 样式 ID | 名称 | firstLine | 行距 | 对齐 | 用途 |
|---------|------|-----------|------|------|------|
| FirstParagraph | 首段 | 480～482 dxa | line=300 | both | 首段、正文、摘要 |
| a0 | Body Text | 480～482 dxa | line=300 | 左 | 续段 |

- 作者行：FirstParagraph + jc=right
- 摘要段：FirstParagraph + jc=both + firstLine=482

### 3.4 三线表格式

| 属性 | 值 |
|------|----|
| 表格样式 | tblStyle="Table" |
| 表格宽度 | 9026 dxa（版心全宽） |
| 上框线 | single，sz=12（1.5pt），黑色 |
| 下框线 | single，sz=12（1.5pt），黑色 |
| 内框线 | 无 |
| 表头行下框线 | single，sz=6（0.75pt），黑色 |
| 单元格内边距 | top=80，left=120，bottom=80，right=120 dxa |
| 单元格段落样式 | Compact，line=300，jc=center |
| 单元格文字字号 | 10.5pt（sz=21） |
| 数据行垂直对齐 | vAlign=center |

**表1列宽**（4列，合计 9026 dxa）：1821 / 1979 / 2700 / 2526

### 3.5 表标题（表注）规范

**规则：三线表必须配置表标题，位于表格正上方紧邻段落。**

| 属性 | 值 |
|------|----|
| 位置 | 表格 `<w:tbl>` 的**正上方**紧邻段落（`</w:p>` 紧接 `<w:tbl>`） |
| 段落样式 | a0（Body Text） |
| 字体 | 黑体（eastAsia=黑体；推荐同时设 ascii=黑体、hAnsi=黑体） |
| 字号 | 继承文档默认（12pt / sz=24），**不单独设置** |
| 行距 | line=300，lineRule=auto（1.5倍） |
| 对齐 | 居中（jc=center） |
| 段前/段后 | before=0，after=0 |
| firstLine | 无（**不设首行缩进**） |
| 文字格式 | `表N 标题内容`（"表"与编号之间无空格，编号后一个全角空格再接标题） |

**XML 模板：**
```xml
<w:p>
  <w:pPr>
    <w:pStyle w:val="a0"/>
    <w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="auto"/>
    <w:jc w:val="center"/>
    <w:rPr>
      <w:rFonts w:ascii="黑体" w:eastAsia="黑体" w:hAnsi="黑体"/>
    </w:rPr>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="黑体" w:eastAsia="黑体" w:hAnsi="黑体"/>
    </w:rPr>
    <w:t>表1 标题内容</w:t>
  </w:r>
</w:p>
<w:tbl>
  <!-- 表格内容 -->
</w:tbl>
```

### 3.6 编号列表规范

- 使用 ①②③④⑤⑥⑦⑧⑨⑩ 圆圈数字，**不使用** `→`、`↓`、`├──` 等符号
- 简短序列：内联于正文句中，用分号"；"分隔
- 较长条目：每条单独成段（BodyText 样式，无 firstLine 缩进）

---

## 四、XML 编辑常用片段

### 设置段落对齐居中
```xml
<w:pPr>
  <w:jc w:val="center"/>
</w:pPr>
```

### 设置字体为黑体（标题用）
```xml
<w:rPr>
  <w:rFonts w:ascii="黑体" w:eastAsia="黑体" w:hAnsi="黑体"/>
  <w:sz w:val="28"/>
  <w:szCs w:val="28"/>
</w:rPr>
```

### 三线表边框（tblBorders）
```xml
<w:tblBorders>
  <w:top w:val="single" w:sz="12" w:space="0" w:color="000000"/>
  <w:bottom w:val="single" w:sz="12" w:space="0" w:color="000000"/>
</w:tblBorders>
```

### 表头行下边框（tcBorders）
```xml
<w:tcBorders>
  <w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>
</w:tcBorders>
```

### 颜色改为纯黑（去除主题色）
```xml
<!-- 替换前（主题色）-->
<w:color w:themeColor="accent1" w:themeShade="BF" w:val="0F4761"/>
<!-- 替换后（纯黑）-->
<w:color w:val="000000"/>
```

---

## 五、常用 Python 操作片段

### 遍历表格单元格并设置居中
```python
for tbl in body.iter(w('tbl')):
    for tc in tbl.iter(w('tc')):
        for para in tc.findall(w('p')):
            pPr = para.find(w('pPr'))
            if pPr is None:
                pPr = ET.Element(w('pPr'))
                para.insert(0, pPr)
            for old in pPr.findall(w('jc')): pPr.remove(old)
            jc = ET.SubElement(pPr, w('jc'))
            jc.set(w('val'), 'center')
```

### 替换 SourceCode 代码块段落为普通段落列表
```python
def replace_code_block(body, sig, new_items):
    for i, child in enumerate(list(body)):
        if child.tag != w('p'): continue
        pPr = child.find(w('pPr'))
        if pPr is None: continue
        pStyle = pPr.find(w('pStyle'))
        if pStyle is None or pStyle.get(w('val')) != 'SourceCode': continue
        text = ''.join(t.text or '' for t in child.iter(w('t')))
        if sig not in text: continue
        body.remove(child)
        for j, txt in enumerate(new_items):
            p = ET.Element(w('p'))
            pPr2 = ET.SubElement(p, w('pPr'))
            ET.SubElement(pPr2, w('pStyle')).set(w('val'), 'BodyText')
            r = ET.SubElement(p, w('r'))
            ET.SubElement(r, w('rPr'))
            t = ET.SubElement(r, w('t'))
            t.set('xml:space', 'preserve')
            t.text = txt
            body.insert(i + j, p)
        return
```

### 修改 styles.xml 中所有标题颜色为黑色
```python
for style in root.findall(f'.//{w("style")}'):
    if not style.get(w('styleId'), '').startswith('Heading'):
        continue
    for rPr in style.iter(w('rPr')):
        for color in rPr.findall(w('color')):
            color.attrib.clear()
            color.set(w('val'), '000000')
```

---

*版本 v1.1 | 2026-03-30 | 东南大学智慧交通 张煜珩*
*迁移至新格式，补充版本日志*
