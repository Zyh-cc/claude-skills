# Claude Skills 技能树

> Claude Code 自我进化经验库——遇到问题先查，解决后记，有更好方法则更新。

## 这是什么

这是一个持续成长的经验库，记录 Claude Code 在实际任务中积累的工具使用经验、踩坑记录和最佳实践。每一篇经验文件都来自真实解决的问题，随时间迭代升级。

## 技能树地图

| 领域 | 文件 | 说明 |
|------|------|------|
| 📥 下载 | [download/github-release.md](download/github-release.md) | 从 GitHub Release 获取真实下载链接 |
| 📥 下载 | [download/gh-api-file-download.md](download/gh-api-file-download.md) | 用 gh api 获取仓库目录文件并下载 |
| 📄 文档 | [document/word-docx.md](document/word-docx.md) | Word .docx 编辑全流程 |
| 🌐 浏览器 | [browser/agent-browser.md](browser/agent-browser.md) | agent-browser 自动化操作 |
| 🔧 技能管理 | [skills-management/skill-lifecycle.md](skills-management/skill-lifecycle.md) | Skill 安装、热加载与管理 |
| 🏗️ 系统架构 | [skills-management/skill-tree-architecture.md](skills-management/skill-tree-architecture.md) | 技能树自进化系统设计与核心待解决问题 |
| ⚙️ 自动化 | [automation/windows-bat.md](automation/windows-bat.md) | Windows bat 脚本编写与全局命令配置 |

## 使用方式

### 作为 Claude 的知识库

将本仓库克隆到本地，在 `~/.claude/CLAUDE.md` 中写入技能库路径，Claude 会在每次任务前自动查阅相关经验。

```bash
git clone https://github.com/Zyh-cc/claude-skills.git E:/ClaudeCode/ClaudeCodeSkills
```

### 查找经验

- 按领域浏览对应文件夹
- 每篇经验文件包含：问题场景、解决方案、踩过的坑、版本日志

## 贡献

欢迎提交你在使用 Claude Code 过程中积累的经验！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 环境说明

- 主要在 Windows 11 + Git Bash 环境下积累
- 适用工具：Claude Code CLI
- 预留对其他 AI Agent 工具的扩展空间
