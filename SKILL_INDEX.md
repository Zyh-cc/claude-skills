# 技能树索引

> 每次任务开始前读此文件（10秒扫完）。匹配到触发词则读对应技能文件。
> 
> **更新规则**：新增/修改技能后必须同步更新此索引。

---

## 📄 document — 文档与写作

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [china-policy-search.md](document/china-policy-search.md) | 中国政府政策文件检索：层级顺序、年份陷阱、可引用格式 | 政策背景、政策文件、规划、论文引用、法规 |
| [word-docx.md](document/word-docx.md) | .docx文件的读取、编辑、创建（含XML直接操作）；中文PDF提取用pdfplumber | .docx、Word文档、docx、PDF提取、pdfplumber、中文PDF、读取pdf、pdf乱码、pdf文字提取 |
| [academic-writing-style-zh.md](document/academic-writing-style-zh.md) | 中文学术论文 AI 腔七类模式检查与修改（排比/定义句/均质句长/方面上述/过渡句/括号/强调词） | AI腔、论文风格、学术写作、查重、综述写作、中文论文、风格检查 |
| [write-conversation-log.md](document/write-conversation-log.md) | 对话日志写作：科研精简风格 + 生活朋友视角两种语态 | 记录日志、写日志、日志、log |
| [chinese-doc-writing-strategy.md](document/chinese-doc-writing-strategy.md) | 四类中文文件写作策略：合作方案、调研方案、新闻稿、学校公文 | 帮我写、写方案、写新闻、写公文、写报告、写材料、起草、写通知、写提案、写调研 |
| [task-driven-thesis-framework.md](document/task-driven-thesis-framework.md) | 导师说"创新点动机不足/缺少需求分析层"时，用五步法重构任务驱动的方法论框架 | 论文框架、导师说框架不行、创新点动机、为什么做这个、缺少需求分析、方法论重构、任务驱动、应用场景 |
| [biweekly-report-docx.md](document/biweekly-report-docx.md) | 为张天承生成两周总结.docx周报（含格式规范、NODE_PATH坑、中文引号坑） | 周报、两周总结、两周报、work report |
| [literature-based-report-verification.md](document/literature-based-report-verification.md) | 调研报告文献引用核查：风险分级、pdftotext+grep工作流、虚构引用识别与修复 | 核查引用、文献核实、调研报告、引用来源、quote核查、pdftotext、查论文原文、引用是否真实 |

---

## 🐛 debugging — 调试经验

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [debug.md](debugging/debug.md) | 修 Bug 通用五步流程：先定位根因、找全同类、提交前自检、失败时先理解再换方案 | bug、修bug、调试、不行了、失效、报错、debug、fix |
| [regression-debugging.md](debugging/regression-debugging.md) | "之前好用，现在坏了" → 先查 git log 找变化点，再谈根因 | 之前可以、退化、regression、之前好用、现在不行 |
| [ffmpeg-rtsp-debugging.md](debugging/ffmpeg-rtsp-debugging.md) | ffmpeg拉取RTSP流失败的排查路径（音频、连接、格式） | ffmpeg、RTSP、摄像头、视频流 |
| [linux-routing-debug.md](debugging/linux-routing-debug.md) | Linux多网卡路由不通的排查与修复 | 路由、routing、网卡、iptables |
| [open3d-windows-chinese-path.md](debugging/open3d-windows-chinese-path.md) | open3d 在 Windows 中文路径下读写 PCD 静默失败，tempfile 中转绕过 | open3d、PCD、中文路径、Windows、read_point_cloud、write_point_cloud |
| [video-lidar-frame-alignment.md](debugging/video-lidar-frame-alignment.md) | 视频与LiDAR点云帧对齐问题（时间戳、帧率匹配） | 帧对齐、时间戳、LiDAR、点云、同步 |
| [whitelist-network-timesync.md](debugging/whitelist-network-timesync.md) | 白名单网络环境下NTP时间同步失败的解决方案 | 时间同步、NTP、内网、白名单 |

---

## ⚙️ automation — 自动化

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [claude-hooks.md](automation/claude-hooks.md) | Claude Code hooks 配置与常见模式 | hooks、钩子、自动执行、before/after |
| [windows-bat.md](automation/windows-bat.md) | Windows bat脚本编写注意事项 | .bat、批处理、Windows脚本 |
| [post-code-review.md](automation/post-code-review.md) | 生成代码后两轮校核：用 code-reviewer 拦截变量作用域/跨文件集成/命名约定 bug | 校核、code review、生成代码后、提交前、审查、检查代码 |

---

## ⬇️ download — 下载

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [github-release.md](download/github-release.md) | 从GitHub Release下载文件的方法（含国内网络） | GitHub Release、下载、gh |
| [gh-api-file-download.md](download/gh-api-file-download.md) | 用GitHub API下载仓库中特定文件 | GitHub API、仓库文件、下载 |

---

## 🔧 config — 配置

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [claude-code-api-switch.md](config/claude-code-api-switch.md) | ⚠️ switch-api会清空plugins和hooks，操作前备份 | API切换、switch-api、settings.json |

---

## 🌐 browser — 浏览器操作

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [playwright-data-verification.md](browser/playwright-data-verification.md) | 用 Playwright 搜百度核实文档数据：判断来源权威性、口径一致性、内外数字差异 | 核实数据、数据来源、数据可靠吗、数字对不上、查一下这个数据 |

---

## 🎨 diagram — 图表与可视化

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [drawio](https://github.com/itoksk/drawio-skill)（第三方，已部署） | 生成 draw.io 原生 .drawio 文件，可导出 PNG/SVG/PDF | 技术路线图、流程图、draw.io、drawio、diagram、画图 |

---

## 🛠️ tools — 工具配置

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [zotero-pdf2zh-setup.md](tools/zotero-pdf2zh-setup.md) | Zotero + pdf2zh 中文翻译插件配置 | Zotero、pdf2zh、文献翻译、PDF翻译 |
| [daily-book.md](tools/daily-book.md) | 像老朋友一样推荐一本书，幽默风趣，涵盖作者、类型、内容、感悟 | 给我讲本书、今天读什么、推荐一本书、每日读书、给我介绍本书、今天看什么书、读书推荐 |

---

## 📊 data-processing — 数据处理

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [点云地面滤除验证.md](data-processing/点云地面滤除验证.md) | CSF点云地面滤除参数选择与验证方法（UAV点云） | 点云、CSF、地面滤除、LiDAR、UAV |
| [项目目录结构重组.md](data-processing/项目目录结构重组.md) | 数据集项目目录批量迁移+脚本路径修正+README同步 | 目录结构、重组、路径、项目整理、硬编码、mv |
| [3d-annotation-tool-selection.md](data-processing/3d-annotation-tool-selection.md) | UAV LiDAR 点云标注工具选型三要素：ry定义/大坐标精度/round-trip | 标注工具、labelCloud、3DBat、KITTI、ry、UTM坐标、点云标注 |
| [聚类预标注调参分析框架.md](data-processing/聚类预标注调参分析框架.md) | 聚类过滤后的调参诊断：置信度分层统计、疑似漏检/误报检测、GUI分析工具设计 | 聚类、预标注、调参、置信度、漏检、误报、DBSCAN、HDBSCAN、analyze_detail |
| [open3d-interactive-review.md](data-processing/open3d-interactive-review.md) | Open3D bbox交互审核：Ray-OBB射线拾取、FP/FN双击标记、窗口缓存保留状态、JSON日志输出 | open3d、交互、鼠标回调、bbox拾取、射线、ray、OBB、FP、FN、标记、审核日志 |
| [tkinter-multi-tool-studio.md](data-processing/tkinter-multi-tool-studio.md) | 多个 tkinter 工具整合为向导式单窗口：parent=None 嵌入模式、StepBar、线程安全、bind_all 坑 | tkinter、整合、向导、单窗口、嵌入、parent、工作台、多工具、GUI整合 |
| [academic-plot.md](data-processing/academic-plot.md) | MATLAB/Python 学术论文图绘制：多子图布局/时间序列样式/传感器数据预处理/导出坑 | 画图、成图、出图效果、复现论文图、MATLAB绘图、Python画图、matplotlib、学术图、传感器、时间序列、子图 |
| [proprietary-binary-reverse-engineering.md](data-processing/proprietary-binary-reverse-engineering.md) | 已知明文攻击破解私有二进制格式：四阶段方法（块结构→记录大小→明文攻击→角度解码），含 DJI L2 LDR 完整速查 | 逆向、二进制格式、私有协议、LDR、DJI、点云流、Euler约定、已知明文攻击、binary reverse engineering |
---

## 🗂️ skills-management — 技能库管理

| 文件 | 一句话描述 | 触发关键词 |
|------|-----------|-----------|
| [resume-work.md](skills-management/resume-work.md) | 继续工作的最小化启动：只拉 progress.md 末尾节，不过度读文件 | 继续、继续工作、继续上次、接着做、resume |
| [create-skill.md](skills-management/create-skill.md) | 把当前经验生成技能的完整七步流程（source→installed→index→deploy→test→push） | 把这个生成技能、写成技能、记录成技能、保存为技能、create skill |
| [greet-with-memory.md](skills-management/greet-with-memory.md) | 用户打招呼时自动并行读取全局记忆和本地记忆 | 你好、hi、hello、早、早上好、开始工作 |
| [skill-lifecycle.md](skills-management/skill-lifecycle.md) | 技能文件的创建、更新、归档规范 | 新建技能、更新技能、技能模板 |
| [skill-tree-architecture.md](skills-management/skill-tree-architecture.md) | 技能树目录结构设计原则 | 技能树结构、分类、组织 |
