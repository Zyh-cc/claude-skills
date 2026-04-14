---
name: claude-code-api-switch
description: Switch Claude Code between official Anthropic account and a third-party relay API (中转站). Use this when the user wants to switch API sources, mentions foxcode/relay/中转站/切换API/API连不上/连接失败, or asks why Claude Code can't connect. Also covers the claudep.bat startup flow and proxy configuration. Triggers on: "切换API", "换中转", "foxcode", "relay", "连不上", "ECONNRESET", "claudep".
---

## File layout

```
C:\TOOLS\
├── claudep.bat         # Smart launcher (auto-detects mode)
└── switch-api.bat      # Switch between API sources

~\.claude\
├── settings.json               # Active config (managed by script)
├── settings.foxcode.json       # Relay API config
└── settings.official.json      # Official account config
```

## Switch commands

```bat
switch-api foxcode     # Switch to relay
switch-api official    # Switch to official account
switch-api             # Interactive menu
```

Restart Claude Code after switching.

**验证切换成功**：
```bat
REM Windows — 检查当前 settings.json 生效的模式
findstr "ANTHROPIC_BASE_URL" %USERPROFILE%\.claude\settings.json
REM 有输出 → foxcode 模式；无输出 → official 模式
```

## How claudep.bat auto-detects mode

Checks if `ANTHROPIC_BASE_URL` exists in settings.json:
- **Present** → foxcode mode: skip proxy, launch directly
- **Absent** → official mode: set Clash Verge proxy (port 7897), check connectivity, launch

## Key variables in settings.foxcode.json

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "<relay API key>",
    "ANTHROPIC_BASE_URL": "<relay server URL>",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

## Why ECONNRESET happens with relay + proxy open

Relay server already handles the GFW bypass. Running Clash Verge simultaneously creates double-proxying:
```
Claude Code → Clash Verge → relay server → api.anthropic.com  ← unstable
```
In foxcode mode, close or ignore Clash Verge for Claude Code.

## Pitfall: switch-api.bat must hardcode CLAUDE_DIR

When bat is in `C:\TOOLS\` but settings JSONs are in `~\.claude\`, `%~dp0` points to the wrong place. Hardcode:
```bat
set CLAUDE_DIR=C:\Users\<username>\.claude\
```

## enabledPlugins and hooks must be in both settings files

Both `settings.foxcode.json` and `settings.official.json` need identical `enabledPlugins` and `hooks` blocks, or they'll disappear after switching.

---

## Linux Server Setup

### File layout

```
~/.claude/
├── settings.json               # Active config
├── settings.foxcode.json       # Relay API config
└── settings.official.json      # Official (proxy) config

~/bin/
└── switch-api                  # Shell script switcher
```

### One-time setup

```bash
# 1. Create official config
cat > ~/.claude/settings.official.json << 'EOF'
{
  "env": {
    "https_proxy": "http://127.0.0.1:7897",
    "http_proxy": "http://127.0.0.1:7897",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
EOF

# 2. Create foxcode config
cat > ~/.claude/settings.foxcode.json << 'EOF'
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "<relay API key>",
    "ANTHROPIC_BASE_URL": "<relay server URL>",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
EOF

# 3. Create switch script
mkdir -p ~/bin
cat > ~/bin/switch-api << 'EOF'
#!/bin/bash
CLAUDE_DIR="$HOME/.claude"

do_switch() {
    case "$1" in
        foxcode)
            cp "$CLAUDE_DIR/settings.foxcode.json" "$CLAUDE_DIR/settings.json"
            echo "[OK] Switched to Foxcode (restart Claude Code to apply)"
            ;;
        official)
            cp "$CLAUDE_DIR/settings.official.json" "$CLAUDE_DIR/settings.json"
            echo "[OK] Switched to Official (restart Claude Code to apply)"
            ;;
    esac
}

if [ "$1" = "foxcode" ] || [ "$1" = "official" ]; then
    do_switch "$1"
    exit 0
fi

echo "Claude Code API Switcher"
echo "========================"
echo "1. Foxcode Relay"
echo "2. Official Account"
echo ""
read -p "Select (1/2): " choice
case "$choice" in
    1) do_switch foxcode ;;
    2) do_switch official ;;
    *) echo "Invalid choice" ; exit 1 ;;
esac
EOF
chmod +x ~/bin/switch-api
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

### Switch commands

```bash
switch-api foxcode     # Switch to relay
switch-api official    # Switch to official (proxy)
switch-api             # Interactive menu (select 1/2)
```

### Pitfall: heredoc EOF must be unindented

If the closing `EOF` has leading spaces, bash waits forever. Each `EOF` must be at column 0. If stuck, type `EOF` and press Enter to exit, then retry.

### Pitfall: Permission denied after overwrite

`cat >` overwrites file content but preserves permissions. If `chmod +x` was run in a previous session, re-running `cat >` keeps the permission. If permission is missing, run `chmod +x ~/bin/switch-api` explicitly.

### No proxy needed in foxcode mode

Relay server handles GFW bypass. Local computer's proxy (Clash Verge, etc.) has no effect on the server.
