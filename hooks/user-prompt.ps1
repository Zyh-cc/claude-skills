$raw = [Console]::In.ReadToEnd()
$input_json = $raw | ConvertFrom-Json
$msg = $input_json.tool_input.message.ToLower()

$matched = @()
Get-ChildItem 'E:\ClaudeCode\ClaudeCodeSkills' -Recurse -Filter '*.md' | Where-Object {
    $_.FullName -notmatch '\.git' -and
    $_.Name -notin @('_template.md','README.md','CONTRIBUTING.md','CLAUDE.md','skill-tree-architecture.md')
} | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $kw_line = ($content -split '\n' | Where-Object { $_ -match 'keywords:' } | Select-Object -First 1)
    if ($kw_line) {
        $keywords = $kw_line -replace '^.*?:\s*','' -split ',' | ForEach-Object { $_.Trim().ToLower() }
        foreach ($kw in $keywords) {
            if ($kw -and $msg -match [regex]::Escape($kw)) {
                $matched += $_; break
            }
        }
    }
}

if ($matched.Count -gt 0) {
    $ctx = "[SkillTree] Relevant experience found - refer to this before proceeding:`n`n"
    foreach ($f in $matched) {
        $rel = $f.FullName.Replace('E:\ClaudeCode\ClaudeCodeSkills\', '')
        $body = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $ctx += "=== $rel ===`n$body`n`n"
    }
    @{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $ctx } } | ConvertTo-Json -Compress -Depth 5
} else {
    '{}'
}
