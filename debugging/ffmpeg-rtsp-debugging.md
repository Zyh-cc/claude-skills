---
title: ffmpeg RTSP 调试经验
keywords: ffmpeg, rtsp, camera, video, audio, encoding, pcm_alaw, mp4, debugging
version: 1.0.0
created: 2026-03-30
updated: 2026-03-30
---

## 版本日志

- **v1.0.0** (2026-03-30)：初始版本，记录 MUST 项目调试中遇到的 ffmpeg + RTSP 问题

---

## 问题场景

使用 ffmpeg 录制 RTSP 摄像头视频流时遇到各种问题。

---

## 常见问题与解决方案

### 1. 音频编码不兼容

**错误信息**：
```
[mp4 @ 0x...] Could not find tag for codec pcm_alaw in stream #1, codec not currently supported in container
Could not write header for output file #0 (incorrect codec parameters ?): Invalid argument
```

**原因**：
- 摄像头输出音频编码为 `pcm_alaw`
- MP4 容器不支持此音频编码

**解决方案**：

方案 1：禁用音频（推荐，最简单）
```bash
ffmpeg -rtsp_transport tcp -i "rtsp://..." -c:v copy -an -t 30 output.mp4
```

方案 2：转换音频编码
```bash
ffmpeg -rtsp_transport tcp -i "rtsp://..." -c:v copy -c:a aac -t 30 output.mp4
```

方案 3：使用 AVI 容器
```bash
ffmpeg -rtsp_transport tcp -i "rtsp://..." -c copy -t 30 output.avi
```


### 2. Shell 特殊字符问题

**错误信息**：
```
[1] 1345
[2] 1346
-bash: -c:v: command not found
```

**原因**：
- RTSP URL 中的 `&` 符号在 bash 中表示后台运行
- 直接粘贴命令会被拆散

**解决方案**：
URL 必须加引号：
```bash
ffmpeg -i "rtsp://192.168.1.192:554/1/h264major/user=admin&password=admin&channel=1&stream=0.sdp?" -c copy output.mp4
```

**代码中的处理**：
使用列表传参给 `subprocess.Popen`，不经过 shell 解析：
```python
cmd = [
    "ffmpeg",
    "-rtsp_transport", "tcp",
    "-i", rtsp_url,  # 不需要引号
    "-c:v", "copy",
    "-an",
    "-t", str(duration),
    "-y", output_path,
]
proc = subprocess.Popen(cmd)
```


### 3. 连接超时

**错误信息**：
```
Connection to tcp://192.168.1.2:554 failed: Connection timed out
```

**可能原因**：
1. IP 地址不正确
2. 摄像头和设备不在同一网络
3. 防火墙阻止连接
4. 摄像头未开启 RTSP 服务

**解决方案**：
1. 确认摄像头 IP（通过路由器管理页面或网络扫描）
2. 确保设备和摄像头在同一网段
3. 测试网络连通性：`ping 摄像头IP`
4. 尝试不同传输协议：`-rtsp_transport tcp` 或 `-rtsp_transport udp`

---

## 调试技巧

### 1. 查看详细信息
```bash
ffmpeg -v verbose -i "rtsp://..." output.mp4
```

### 2. 测试连接（不录制）
```bash
ffmpeg -i "rtsp://..." -t 1 -f null -
```

### 3. 查看流信息
```bash
ffmpeg -i "rtsp://..." 2>&1 | grep Stream
```

---

## 踩过的坑

1. **退出码 0 但文件不存在**：ffmpeg 进程成功退出但文件未生成，可能是文件系统、权限或工作目录问题（MUST 项目遇到，原因待查）

2. **音频编码问题容易被忽略**：错误信息可能不明显，需要仔细查看 ffmpeg 输出

3. **URL 特殊字符**：命令行测试时必须加引号，代码中用列表传参

