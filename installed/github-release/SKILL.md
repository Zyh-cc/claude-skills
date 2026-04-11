---
name: github-release
description: Download files from GitHub Release pages using gh CLI. Use this whenever you need to get a download URL or download an installer/asset from a GitHub releases page — even if the user just says "download the latest version" or "get the .exe/.msi from GitHub".
---

## Recommended approach: gh CLI

```bash
# Get download URL for a specific asset
gh release view <tag> --repo <owner/repo> --json assets \
  --jq '.assets[] | select(.name | test("Windows.msi$")) | .url'

# Download
curl -L -o "target/file.msi" "<url>"

# Latest release
gh release view latest --repo <owner/repo> --json assets --jq '.assets[].name'
```

## Fallback: agent-browser + gh CLI

WebFetch cannot see GitHub release assets (JS-rendered). Use agent-browser to identify the filename, then gh CLI to get the real URL.

```bash
agent-browser open https://github.com/<owner>/<repo>/releases/latest
agent-browser wait --load networkidle
agent-browser snapshot -i
# Find filename in snapshot, then use gh CLI for the actual URL
```

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| WebFetch sees no download links | Assets section is JS-rendered | Use gh CLI instead |
| agent-browser snapshot has no URL | Asset links not exposed as `link` refs | Use gh CLI to get URL |
| curl progress bar garbled | Terminal control chars unsupported | Run with `! curl ...` in terminal |
| Newly installed skill not found | Skill list fixed at session start | Restart session |

## Tool selection

| Scenario | Tool |
|----------|------|
| Static page content | WebFetch |
| JS-rendered page | agent-browser |
| GitHub release asset URL | `gh release view --json assets` |
