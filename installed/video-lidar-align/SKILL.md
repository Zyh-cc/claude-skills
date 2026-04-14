---
name: video-lidar-align
description: Align video frames with LiDAR point cloud frames at millisecond precision. Use this when building multi-modal datasets combining camera video and LiDAR, synchronizing timestamps across sensors, or debugging time alignment issues. Triggers on: "时间对齐", "帧对齐", "视频LiDAR同步", "timestamp sync", "PTS", "DJI L2时间", "MRK时间", "切帧卡死"
---

## 快速入口

- **UAV 数据（DJI L2 + 视频）** → Section 1
- **MUST 路侧系统（Jetson + 摄像头 + LiDAR）** → Section 2

---

## Section 1：UAV 数据对齐（DJI L2）

### DJI L2 三种时间系统（混用必卡死）

| 来源 | 时间系统 | 示例值 |
|------|----------|--------|
| LAS `gps_time` | Adjusted GPS Time（从1980-01-06起，减去1e9） | ~458,446,439 |
| `terra_trajectory` GPS_Time | Unix 时间戳（从1970-01-01起） | ~1,774,411,236 |
| MRK 第二列 | GPS 周内秒（0~604800，周日0点重置） | ~273,637 |

**LAS → Traj 偏移**：从数据推算，不要硬编码：
```python
las_to_traj_offset = traj['GPS_Time'].iloc[0] - all_t.min()
```

### Step 1：切帧起点用 LAS 实际最早时刻

```python
# ✅ 正确
curr_t = all_t.min()

# ❌ 错误：用 MRK SOW (~273637) 作起点
# while 循环需迭代45亿次空帧，脚本卡死
```

### Step 2：位姿查找统一到同一时间系统

```python
frame_center_t_traj = curr_t + FRAME_DT / 2 + las_to_traj_offset
pose_idx = (traj['GPS_Time'] - frame_center_t_traj).abs().idxmin()
```

### Step 3：视频帧绝对时间（用 PTS，不用 OSD）

```
frame_absolute_time = 文件名起始时间 + PTS_offset
```

OSD 时间戳（屏显时钟）与对齐无关，忽略即可（即使显示 2023 年也没关系）。

```bash
# 提取 PTS
ffprobe -v quiet -select_streams v:0 \
  -show_entries frame=pts_time \
  -of csv=p=0 input.mp4
```

```python
from datetime import datetime, timedelta
import subprocess

def get_frame_timestamps(video_path, file_start_time):
    result = subprocess.run([
        "ffprobe", "-v", "quiet", "-select_streams", "v:0",
        "-show_entries", "frame=pts_time", "-of", "csv=p=0", video_path
    ], capture_output=True, text=True)
    return [
        file_start_time + timedelta(seconds=float(line))
        for line in result.stdout.strip().split("\n")
    ]
```

---

## Section 2：MUST 路侧系统对齐（Jetson）

### 已验证配置（不需要再调）

| 传感器 | 时间精度 | 对齐方式 |
|--------|----------|----------|
| Jetson 主机 | 秒级（OSS响应头软校时） | 文件名时间戳 |
| 摄像头 OSD | 不可用（显示2023年） | 忽略，用文件名+PTS |
| LiDAR | 与 Jetson 同步 | 文件名时间戳 |

**Jetson 时间校准**：开机通过 OSS HTTP Date 响应头校时，秒级精度，满足帧对齐需求（帧间隔 ≥ 66ms）。

### 跨传感器精校准（移动目标法）

当需要毫秒级精度（如发表数据集）时：

1. 采集时让车辆同时经过 LiDAR FOV 和摄像头 FOV
2. 在两路数据中找到同一辆车的出现/消失时刻
3. 时间偏移 = 使两侧车辆位置最优匹配的 delta_t

---

## Pitfalls

| 问题 | 原因 | 解决 |
|------|------|------|
| 切帧脚本卡死（空帧） | 用 MRK SOW 作 curr_t 起点 | 改用 `all_t.min()` |
| 所有帧位姿相同 | LAS time 直接与 Unix traj time 做差，差值恒为~1.3e9 | 用 `las_to_traj_offset` 统一时间系统 |
| 帧时间戳不均匀 | ffmpeg 偶发丢帧 | 用 ffprobe 提取实际 PTS，不用 `frame_idx × (1/fps)` |
| OSD 显示年份错误 | 摄像头 RTC 未校准 | 无关，用 PTS + 文件名时间 |
