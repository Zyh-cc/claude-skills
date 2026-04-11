---
name: claude-hooks
description: Configure Claude Code hooks in settings.json to run shell commands on session events. Use this when the user wants to automate something on session start, after each message, or after Claude finishes responding — like injecting context, loading skill trees, or logging.
---

## Hook configuration

In `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "PostToolUse": [{ "hooks": [{ "type": "command", "command": "..." }] }]
  }
}
```

## Inject context into Claude (invisible to user)

```bash
echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "content here"}}'
```

## Show message to user

```bash
echo '{"systemMessage": "message content"}'
```

## Recommended structure: external scripts

Keep hook commands simple in JSON; put logic in external scripts:

```
E:\ClaudeCode\ClaudeCodeSkills\hooks\
├── session-start.ps1
└── user-prompt.ps1
```

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command",
      "command": "powershell -ExecutionPolicy Bypass -File 'E:\\path\\session-start.ps1'" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command",
      "command": "cat | powershell -ExecutionPolicy Bypass -File 'E:\\path\\user-prompt.ps1'" }] }]
  }
}
```

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `shell: "powershell"` errors | Claude Code doesn't support `shell` field | Remove `shell` field, call ps1 via bash |
| Chinese in hook command corrupts JSON | UTF-8/GBK mismatch | Only ASCII in hook commands; Chinese goes in external scripts |
| `UserPromptSubmit` can't read stdin | Timing issue with direct read | Pipe explicitly: `cat \| powershell -File script.ps1` |
