---
领域: debugging
版本: v1.0
最后更新: 2026-04-03
适用工具: Claude Code
---

# 白名单网络环境下的系统时间校准（用 HTTP 响应头替代 NTP）

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-03 | 初始版本，来自 MUST 项目调试 |

## 问题场景

边缘设备（如 Jetson Nano）部署在 SIM 卡路由器下，运营商设置了白名单，只允许访问特定域名（如阿里云 OSS），NTP 时间服务器被拦截。设备长时间运行后系统时间漂移，导致需要鉴权的 API 请求失败（如 OSS 返回 403 `RequestTimeTooSkewed`）。

## 解决方案

### 推荐方案：从 HTTP 响应头获取时间

所有 HTTP 服务器的响应头都包含 `Date` 字段，表示服务器当前时间。利用白名单内可访问的服务（如 OSS）的响应头来校准系统时间。

```python
# timesync.py
import requests
import subprocess
from datetime import datetime, timezone

OSS_URL = "http://nanjing-must.oss-cn-shanghai.aliyuncs.com"

def sync_time():
    resp = requests.head(OSS_URL, timeout=10)
    date_str = resp.headers.get("Date")
    # 格式：Fri, 03 Apr 2026 04:08:27 GMT
    dt = datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S %Z")
    dt = dt.replace(tzinfo=timezone.utc)
    time_str = dt.strftime("%Y-%m-%d %H:%M:%S")
    subprocess.run(["date", "-u", "-s", time_str], check=True)
```

### 开机自启（systemd）

```ini
# timesync.service
[Unit]
Description=Time Sync via HTTP
After=network-online.target
Wants=network-online.target
Before=must.service   # 在主服务前运行

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/python3 /path/to/timesync.py

[Install]
WantedBy=multi-user.target
```

```bash
sudo cp timesync.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable timesync.service
```

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 精度只有秒级 | HTTP Date 字段精度为秒 | 对大多数场景（OSS 要求15分钟内）足够 |
| 需要 root 权限 | `date -s` 修改系统时间需要 root | service 不指定 User，默认以 root 运行 |
| 程序误判断网络断开 | 原代码 ping baidu.com，白名单内不可访问 | 改为检测白名单内可访问的域名 |

## 相关经验

- [ffmpeg-rtsp-debugging.md](./ffmpeg-rtsp-debugging.md) — 同一项目（MUST）的摄像头调试经验
