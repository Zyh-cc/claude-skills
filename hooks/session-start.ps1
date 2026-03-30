$skills = Get-ChildItem 'E:\ClaudeCode\ClaudeCodeSkills' -Recurse -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '\.git' -and $_.Name -notin @('_template.md','README.md','CONTRIBUTING.md','CLAUDE.md') } |
    ForEach-Object { $_.FullName.Replace('E:\ClaudeCode\ClaudeCodeSkills\', '') }

$list = ($skills -join '; ')
$ctx = "MANDATORY: Before starting any task this session, check the skill tree for relevant experience. Available skills: $list"

@{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $ctx } } | ConvertTo-Json -Compress
