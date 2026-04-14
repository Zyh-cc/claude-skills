---
name: ffmpeg-rtsp-debug
description: Debug ffmpeg RTSP camera stream recording issues. Use this when ffmpeg fails to record from an IP camera, RTSP connection times out, audio codec errors appear, or shell special characters cause command failures. Triggers on: "ffmpeg录制失败", "摄像头连不上", "RTSP断流", "音频编码错误", "pcm_alaw", "RTSP超时", "ffmpeg RTSP".
---

## 快速诊断

| 错误关键词 | 跳到 |
|------------|------|
| `pcm_alaw` / `Could not find tag for codec` | → 音频编码不兼容 |
| `-bash: -c:v: command not found` | → URL含`&`特殊字符 |
| `Connection timed out` / `Connection refused` | → 连接超时 |
| 命令返回0但无输出文件 | → 路径/权限问题（Pitfall） |

---

## Common issues

### Audio codec incompatible with MP4

```
Could not find tag for codec pcm_alaw in stream #1
```

**Fix — Option 1: disable audio (recommended)**
```bash
ffmpeg -rtsp_transport tcp -i "rtsp://..." -c:v copy -an -t 30 output.mp4
```

**Fix — Option 2: transcode audio**
```bash
ffmpeg -rtsp_transport tcp -i "rtsp://..." -c:v copy -c:a aac -t 30 output.mp4
```

### Shell special characters (`&` in URL)

```
-bash: -c:v: command not found
```

The `&` in RTSP URLs is interpreted by bash as background operator. Always quote the URL:
```bash
ffmpeg -i "rtsp://192.168.1.192:554/...&channel=1&stream=0.sdp?" -c copy output.mp4
```

In Python, use list args to bypass shell entirely:
```python
cmd = ["ffmpeg", "-rtsp_transport", "tcp", "-i", rtsp_url, "-c:v", "copy", "-an", "-t", "30", "-y", output_path]
subprocess.Popen(cmd)
```

### Connection timeout

```
Connection to tcp://192.168.1.2:554 failed: Connection timed out
```

Checklist:
1. Correct camera IP (check router admin page)
2. Same network segment as camera
3. Try both `-rtsp_transport tcp` and `udp`
4. Test: `ping <camera-ip>`

## Debug commands

```bash
# Verbose output
ffmpeg -v verbose -i "rtsp://..." output.mp4

# Test connection without recording
ffmpeg -i "rtsp://..." -t 1 -f null -

# View stream info
ffmpeg -i "rtsp://..." 2>&1 | grep Stream
```

## Pitfall

Exit code 0 but no output file: possible filesystem/permission/working-directory issue. Check that the output path exists and is writable.
