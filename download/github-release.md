---
领域: download
版本: v1.0
最后更新: 2026-03-30
适用工具: Claude Code
keywords: github, release, download, msi, exe, assets, gh, 下载, 安装包, 发布包
---

# 从 GitHub Release 页面获取真实下载链接

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-30 | 初始版本，记录 WebFetch/agent-browser/gh CLI 三种方案 |

## 问题场景

需要从 GitHub releases 页面获取软件安装包的真实下载链接，并下载到本地指定目录。

## 解决方案

### 推荐方案：gh CLI（最直接）

```bash
# 获取指定版本的 Windows MSI 下载链接
gh release view <版本号> --repo <owner/repo> --json assets \
  --jq '.assets[] | select(.name | test("Windows.msi$")) | .url'

# 下载
curl -L -o "目标路径/文件名.msi" "<上面获取的URL>"
```

### 备选方案：agent-browser（适合需要交互页面的场景）

```bash
agent-browser open https://github.com/<owner>/<repo>/releases/latest
agent-browser wait --load networkidle
agent-browser snapshot -i
# 在 snapshot 中找文件名对应的 ref，再用 gh CLI 获取真实 URL
```

> 注意：agent-browser 的 snapshot 通常只能看到文件名，拿不到真实下载 URL，仍需配合 gh CLI。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| WebFetch 看不到下载链接 | GitHub Assets 区域是 JS 动态渲染 | 改用 gh CLI 或 agent-browser |
| agent-browser snapshot 无 URL | Assets 链接未以 `link` 形式暴露 | 用 gh CLI 补充获取 |
| curl 进度条乱码 | 终端控制字符在 Claude 输出环境中无法渲染 | 建议用户在终端自行运行，或用 `! curl ...` |
| skill 安装后热加载失败 | session 启动时 skill 列表已固定 | 重启 session，或手动读取 skill 文件按命令操作 |

## 最终有效路径

```
WebFetch 失败
→ agent-browser 打开页面（能看到文件名，但无 URL）
→ gh CLI 获取真实下载链接
→ curl 下载成功
```

## 工具选择速查

| 场景 | 推荐工具 |
|------|----------|
| 静态网页内容抓取 | `WebFetch` |
| JS 动态渲染页面 | `agent-browser` |
| GitHub release 资产 URL | `gh release view --json assets` |
| session 内新安装的 skill | 重启 session 或手动读取 skill 文件 |
| 需要用户看到进度条 | 建议用户在终端运行或用 `! curl ...` |

## 相关经验

- [skills-management/skill-lifecycle.md](../skills-management/skill-lifecycle.md) — Skill 安装与热加载问题
- [browser/agent-browser.md](../browser/agent-browser.md) — agent-browser 详细用法
