---
name: video-lidar-align
description: Align video frames with LiDAR point cloud frames at millisecond precision for multi-modal datasets. Use this when building datasets that combine camera video and LiDAR, synchronizing timestamps across sensors, or computing per-frame absolute timestamps from a video file.
---

## Core principle

**Camera OSD timestamp (on-screen clock overlay) is irrelevant for alignment.** Use PTS (Presentation Timestamp) from the video container instead.

| Source | What it is | Use for alignment? |
|--------|-----------|-------------------|
| OSD overlay text | Camera's internal clock drawn on frame | ❌ No |
| Container PTS | Time offset from video start | ✅ Yes |

## Frame absolute timestamp formula

```
frame_absolute_time = file_start_time (from filename) + PTS_offset
```

Example: `2026-04-03_14-32-00.mp4`, 15fps, frame 300:
```
14:32:00.000 + 300 × (1/15s) = 14:32:20.000
```

## Extract PTS with ffprobe

```bash
ffprobe -v quiet -select_streams v:0 \
  -show_entries frame=pts_time \
  -of csv=p=0 input.mp4
```

```python
import subprocess
from datetime import datetime, timedelta

def get_frame_timestamps(video_path: str, file_start_time: datetime):
    result = subprocess.run([
        "ffprobe", "-v", "quiet", "-select_streams", "v:0",
        "-show_entries", "frame=pts_time", "-of", "csv=p=0", video_path
    ], capture_output=True, text=True)
    return [
        file_start_time + timedelta(seconds=float(line))
        for line in result.stdout.strip().split("\n")
    ]
```

## LiDAR frame timestamps

```python
lidar_frame_time = file_start_time + timedelta(seconds=frame_idx * (1/10))  # 10Hz
```

## Cross-platform time alignment (Jetson + UAV GPS)

Two independent clocks:
- Jetson: HTTP header sync, second-level precision
- UAV: GPS UTC, microsecond precision

**Calibration (moving target method):** have a vehicle pass through both LiDAR and UAV FOV simultaneously during collection; find the time offset where vehicle positions best match across both sensors.

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| OSD shows wrong year (e.g., 2023) | Camera RTC not calibrated | Irrelevant — use PTS + filename time |
| Frame timestamps uneven | ffmpeg drops frames occasionally | Use actual PTS from ffprobe, not `frame_idx × (1/fps)` |
