---
name: github-release
description: Download files from GitHub Release pages using gh CLI. Use this whenever you need to get a download URL or download an installer/asset from a GitHub releases page — even if the user just says "download the latest version" or "get the .exe/.msi from GitHub". Triggers on: "GitHub下载", "下载release", "下载安装包", "GitHub最新版本", "下载.exe/.msi", "gh release".
---

## 工具选择（先看这里）

| 场景 | 工具 |
|------|------|
| GitHub Release 资产文件（installer/binary） | `gh release view --json assets` |
| JS渲染页面（看不到资产列表） | agent-browser 识别文件名 → gh CLI 获取URL |
| 普通静态页面内容 | WebFetch |

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

