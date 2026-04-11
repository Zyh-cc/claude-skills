# Claude Skills — Personal Skill Tree for Claude Code

> A self-evolving knowledge base for Claude Code. Every skill is a real problem solved, distilled into reusable experience.

---

## 1. Project Overview

This repository stores accumulated experience from real Claude Code sessions — debugging logs, tool usage patterns, configuration recipes, and domain-specific workflows. It serves as a **persistent memory layer** that makes Claude progressively smarter across sessions.

Each skill is stored in two forms:

- **Source** (`<category>/<skill>.md`) — Full version with version history, context, and detailed pitfall analysis. Written for humans and Claude alike.
- **Installed** (`installed/<skill>/SKILL.md`) — Streamlined version deployed to `~/.claude/skills/`, auto-loaded by Claude Code at session start.

---

## 2. How It Works

The skill tree is wired into Claude Code through three mechanisms:

```
┌─────────────────────────────────────────────────────────┐
│                     Session Start                        │
│  hooks/session-start.ps1 → injects skill file list      │
│                     into Claude's context                │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                   Each User Message                      │
│  hooks/user-prompt.ps1 → keyword match against          │
│  source skills → injects matched skill content          │
│  (0 extra tokens if no match)                           │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                 Explicit Skill Invocation                │
│  installed/ skills auto-loaded by Claude Code →         │
│  Claude invokes via Skill tool when relevant            │
└─────────────────────────────────────────────────────────┘
```

**Source skills** are injected automatically based on keyword matching — Claude sees the full content without explicitly asking. **Installed skills** are always discoverable by Claude Code and invoked on demand. The two layers complement each other.

---

## 3. Project Structure

```
claude-skills/
│
├── README.md                  # This file
├── SKILL_INDEX.md             # Quick lookup index (read before every task)
├── CONTRIBUTING.md            # Contribution guidelines
├── _template.md               # Template for new source skills
├── .gitignore
│
├── hooks/                     # Session automation scripts
│   ├── session-start.ps1      # Injects skill file list at session start
│   └── user-prompt.ps1        # Keyword-based skill injection per message
│
├── installed/                 # Streamlined skills → deploy to ~/.claude/skills/
│   ├── github-release/SKILL.md
│   ├── gh-api-file-download/SKILL.md
│   ├── windows-bat/SKILL.md
│   ├── claude-hooks/SKILL.md
│   ├── claude-code-api-switch/SKILL.md
│   ├── china-policy-search/SKILL.md
│   ├── ffmpeg-rtsp-debug/SKILL.md
│   ├── linux-routing-debug/SKILL.md
│   ├── whitelist-timesync/SKILL.md
│   ├── video-lidar-align/SKILL.md
│   ├── pointcloud-ground-filter/SKILL.md
│   └── zotero-pdf2zh/SKILL.md
│
├── automation/                # Windows automation, bat scripts, hooks
├── browser/                   # Browser automation
├── config/                    # Claude Code configuration
├── data-processing/           # Point cloud, sensor data
├── debugging/                 # Debugging logs and fix recipes
├── document/                  # Document processing, academic writing
├── download/                  # File download from GitHub and other sources
├── skills-management/         # Meta: skill tree architecture and lifecycle
└── tools/                     # Tool setup guides (Zotero, etc.)
```

---

## 4. How to Use

### Deploy to a new machine

```bash
# 1. Clone the repo
git clone https://github.com/Zyh-cc/claude-skills.git E:/ClaudeCode/ClaudeCodeSkills

# 2. Copy installed skills to Claude's skill directory
# Windows (PowerShell):
$base = "E:\ClaudeCode\ClaudeCodeSkills\installed"
$dest = "$env:USERPROFILE\.claude\skills"
Get-ChildItem $base -Directory | ForEach-Object {
    $dst = Join-Path $dest $_.Name
    New-Item -ItemType Directory $dst -Force | Out-Null
    Copy-Item (Join-Path $_.FullName "SKILL.md") $dst
}

# 3. Register hooks in ~/.claude/settings.json:
# SessionStart:    powershell -ExecutionPolicy Bypass -File 'E:\ClaudeCode\ClaudeCodeSkills\hooks\session-start.ps1'
# UserPromptSubmit: cat | powershell -ExecutionPolicy Bypass -File 'E:\ClaudeCode\ClaudeCodeSkills\hooks\user-prompt.ps1'

# 4. Point CLAUDE.md at the skill tree (add to ~/.claude/CLAUDE.md):
# 技能库：E:\ClaudeCode\ClaudeCodeSkills\
```

### Look up a skill

Open `SKILL_INDEX.md` — scan the trigger keywords, follow the link to the relevant skill file.

### Invoke a skill in Claude Code

Claude Code auto-invokes installed skills when it detects a match. You can also explicitly say:
> "Use the `windows-bat` skill to help me write this script."

---

## 5. Maintenance and Extension

### Adding a new skill

1. **Create source file**: copy `_template.md` to `<category>/<skill-name>.md`, fill in problem/solution/pitfalls
2. **Add keywords**: add a `keywords:` field in the frontmatter (ASCII only) for hook-based matching
3. **Create installed version**: create `installed/<skill-name>/SKILL.md` — streamlined version with no version history, only practical commands and pitfalls
4. **Update index**: add a row to `SKILL_INDEX.md`
5. **Deploy installed version**: copy to `~/.claude/skills/<skill-name>/SKILL.md`
6. **Push to GitHub**: `git add . && git commit -m "feat: add <skill-name> skill" && git push`

### Updating an existing skill

1. Edit the **source file** (truth source for full context)
2. Update the **installed version** to reflect any changed commands or new pitfalls
3. Sync installed version to `~/.claude/skills/<skill-name>/SKILL.md`
4. Push both changes

### Skill file structure

**Source skill** (full version):
```markdown
---
领域: category
版本: v1.0
最后更新: YYYY-MM-DD
keywords: keyword1, keyword2, ...   # ASCII only, used by hooks
---

# Title
## 版本日志
## 问题场景
## 解决方案
## 踩过的坑
## 相关经验
```

**Installed skill** (`SKILL.md`):
```markdown
---
name: skill-name
description: One-line description of what this does and when to trigger it.
---

## Core commands / workflow
## Pitfalls
```

### Categories

| Directory | What goes here |
|-----------|---------------|
| `automation/` | Scripts, bat files, hooks, scheduled tasks |
| `browser/` | Web scraping, browser automation |
| `config/` | Claude Code and tool configuration |
| `data-processing/` | Point cloud, sensor fusion, data pipelines |
| `debugging/` | Bug fixes, environment debugging |
| `document/` | Document editing, academic writing |
| `download/` | File retrieval from GitHub, APIs, web |
| `skills-management/` | Meta: how this skill tree works |
| `tools/` | Third-party tool setup and configuration |

Add a new category by creating a new directory — no other config needed.

---

## Environment

- Developed on: Windows 11 + Git Bash
- Primary tool: Claude Code CLI
- Hook scripts: PowerShell 5+
