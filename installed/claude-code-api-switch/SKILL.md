---
name: claude-code-api-switch
description: Switch Claude Code between official Anthropic account and a third-party relay API (中转站). Use this when the user wants to switch API sources, mentions foxcode/relay/中转站, or asks why Claude Code can't connect. Also covers the claudep.bat startup flow and proxy configuration.
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
