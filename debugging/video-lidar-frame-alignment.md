---
领域: debugging
版本: v1.0
最后更新: 2026-04-03
适用工具: Claude Code
---

# 视频帧与LiDAR点云帧级时间对齐（多模态传感器融合）

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-03 | 初始版本，来自 MUST 项目空地协同数据集研究 |

## 问题场景

做多模态数据集（视频 + LiDAR）时，需要知道每一帧视频对应哪个 LiDAR 帧，实现毫秒级精度的帧级对齐。

常见误区：以为摄像头画面右上角显示的时间（OSD）就是帧时间戳，拿它做对齐。

## 核心结论

**摄像头 OSD 时间（画面上叠加的时钟文字）与数据对齐无关。**

视频帧的时间信息来自两个地方：
| 来源 | 说明 | 是否用于对齐 |
|------|------|------------|
| OSD 叠加文字 | 摄像头把内部时钟"画"在画面上，纯显示 | ❌ 不用 |
| 视频容器 PTS | Presentation Timestamp，相对计数器，表示该帧距视频开头的偏移 | ✅ 用这个 |

PTS 不依赖摄像头内部时钟，即使摄像头时间显示 2023 年也不影响。

## 帧级对齐方案

### 公式

```
帧绝对时间 = 文件名时间（采集端系统时钟）+ 该帧PTS偏移量
```

### 示例

文件 `2026-04-03_14-32-00.mp4`，摄像头 15fps，第300帧：
```
14:32:00.000 + 300 × (1/15) 秒 = 14:32:20.000
```

### Python 实现（用 ffprobe 提取 PTS）

```bash
# 提取所有帧的 PTS（单位：秒）
ffprobe -v quiet -select_streams v:0 \
  -show_entries frame=pts_time \
  -of csv=p=0 input.mp4
```

```python
import subprocess
from datetime import datetime, timedelta

def get_frame_timestamps(video_path: str, file_start_time: datetime):
    """
    返回每帧的绝对时间戳列表。
    file_start_time: 文件名解析出的录制开始时间（采集端系统时钟）
    """
    result = subprocess.run([
        "ffprobe", "-v", "quiet",
        "-select_streams", "v:0",
        "-show_entries", "frame=pts_time",
        "-of", "csv=p=0",
        video_path
    ], capture_output=True, text=True)

    timestamps = []
    for line in result.stdout.strip().split("\n"):
        pts = float(line)
        timestamps.append(file_start_time + timedelta(seconds=pts))
    return timestamps
```

### LiDAR 帧时间戳

```python
# 文件名解析开始时间 + 帧序号 × 帧间隔
lidar_frame_time = file_start_time + timedelta(seconds=frame_idx * (1/10))  # 10Hz
```

## 空地时间对齐补充（Jetson vs 无人机 GPS UTC）

路侧 Jetson 和无人机是两个独立时钟系统：
- Jetson：OSS 响应头软同步，精度秒级～毫秒级
- 无人机：GPS UTC 授时，精度微秒级

**标定方法（活靶标法）**：采集时让一辆运动车辆同时出现在路侧 LiDAR 和无人机视野中，事后找两端数据中该车位置最一致的时间偏移量，作为固定时间偏差。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 以为 OSD 时间影响对齐 | 混淆了显示时间和数据时间戳 | 用 PTS + 文件名时间，不看 OSD |
| 摄像头内部时钟显示 2023 年 | 摄像头 RTC 未校准且 NTP 被白名单拦截 | 不影响对齐，忽略即可 |
| 假设帧率恒定 | ffmpeg 偶发丢帧时实际 PTS 不均匀 | 用 ffprobe 提取真实 PTS，而非 frame_idx × (1/fps) |

## 相关经验

- [whitelist-network-timesync.md](./whitelist-network-timesync.md) — 白名单网络下 NTP 不可用时的校时方案
- [linux-routing-debug.md](./linux-routing-debug.md) — 同一项目的路由排查经验
