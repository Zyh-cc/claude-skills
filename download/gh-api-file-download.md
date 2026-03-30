---
领域: download
版本: v1.0
最后更新: 2026-03-30
适用工具: Claude Code
keywords: github, download, api, contents, weeklynews, gh, report, 下载, 仓库, 拉取, 报告
---

# 用 gh api 获取仓库目录文件并下载

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-30 | 初始版本 |

## 问题场景

需要从 GitHub 仓库的某个目录中找到最新文件并下载，文件不是 release 资产，而是直接提交在仓库里的（如定期生成的报告文档）。

## 解决方案

### 推荐方案：gh api contents

```bash
# 列出目录下所有文件，按名称排序取最新一个
gh api repos/<owner>/<repo>/contents/<path> \
  --jq "[.[] | .name] | sort | reverse | .[0]"

# 获取该文件的下载链接
gh api repos/<owner>/<repo>/contents/<path>/<filename> \
  --jq ".download_url"

# 下载
curl -L -o "本地路径/文件名" "<download_url>"
```

### 实际示例（weeklynews 项目）

```bash
# 获取最新报告文件名
gh api repos/Zyh-cc/weeklynews/contents/reports \
  --jq "[.[] | .name] | sort | reverse | .[0]"

# 获取下载链接
gh api repos/Zyh-cc/weeklynews/contents/reports/WeeklyNews_2026-03-30.docx \
  --jq ".download_url"
```

### 封装为 bat 脚本（Windows 自动化）

```bat
@echo off
for /f "delims=" %%i in ('gh api repos/<owner>/<repo>/contents/<path> --jq "[.[] | .name] | sort | reverse | .[0]"') do set LATEST=%%i
gh api repos/<owner>/<repo>/contents/<path>/%LATEST% --jq ".download_url" > %TEMP%\url.txt
set /p URL=<%TEMP%\url.txt
curl -L -o "目标路径\%LATEST%" "%URL%"
```

## 与 gh release 的区别

| 场景 | 工具 |
|------|------|
| 文件在 GitHub Releases 的 Assets 里 | `gh release view --json assets` |
| 文件直接提交在仓库目录里 | `gh api repos/.../contents/...` |

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| `download_url` 为 null | 文件超过 1MB 时 contents API 不返回内容 | 改用 `git.url` 或先 clone 仓库 |
| 文件名含中文导致 URL 编码问题 | curl 不自动处理 | 文件名尽量用英文+日期格式 |

## 相关经验

- [download/github-release.md](./github-release.md) — gh release 下载发布包
- [automation/windows-bat.md](../automation/windows-bat.md) — 封装为 bat 命令
