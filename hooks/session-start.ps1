# SessionStart hook - lightweight skill reminder
$ctx = "Personal skills are available via the Skill tool (~/.claude/skills/). Use them proactively when relevant."
@{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $ctx } } | ConvertTo-Json -Compress
