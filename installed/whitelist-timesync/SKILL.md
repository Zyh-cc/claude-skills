---
name: whitelist-timesync
description: Sync system time on edge devices (Jetson, Raspberry Pi) when NTP is blocked by a whitelist network. Use this when a device behind a carrier SIM router or firewall can't reach NTP servers and time drift causes API auth failures (like OSS 403 RequestTimeTooSkewed).
---

## Problem

Edge device on SIM router with domain whitelist → NTP blocked → clock drifts → OSS/API returns 403 `RequestTimeTooSkewed`.

## Solution: use HTTP response header Date field

Any HTTP server returns a `Date` header with current server time. Use a whitelisted service (e.g., Aliyun OSS) as time source.

```python
# timesync.py
import requests, subprocess
from datetime import datetime, timezone

OSS_URL = "http://<your-bucket>.oss-cn-<region>.aliyuncs.com"

def sync_time():
    resp = requests.head(OSS_URL, timeout=10)
    date_str = resp.headers.get("Date")
    # Format: Fri, 03 Apr 2026 04:08:27 GMT
    dt = datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S %Z")
    dt = dt.replace(tzinfo=timezone.utc)
    subprocess.run(["date", "-u", "-s", dt.strftime("%Y-%m-%d %H:%M:%S")], check=True)
```

## Auto-start with systemd (before main service)

```ini
# /etc/systemd/system/timesync.service
[Unit]
Description=Time Sync via HTTP
After=network-online.target
Wants=network-online.target
Before=<your-main-service>.service

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

## Notes

- Precision: second-level (HTTP Date field) — sufficient for OSS (15-minute tolerance)
- Requires root: `date -s` needs root; service runs as root by default
- Network check: ping whitelisted domain, not baidu.com
