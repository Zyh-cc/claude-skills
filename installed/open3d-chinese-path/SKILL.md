---
name: open3d-chinese-path
description: Use when open3d fails to read or write PCD files on Windows with Chinese characters in the path — symptoms include silent empty point cloud returned, encoding error, or file corruption. Fix via tempfile detour. Triggers on: "open3d读取失败", "点云为空", "中文路径", "open3d中文", "PCD读不出来", "read_point_cloud返回空".
---

## Root cause

open3d's C++ backend on Windows decodes UTF-8 paths as GBK — Chinese characters fail silently (no exception, just empty result).

## Fix: tempfile detour

```python
import os, shutil, tempfile
from pathlib import Path
import open3d as o3d

def read_pcd(path: Path) -> o3d.geometry.PointCloud:
    if os.name == "nt" and not path.as_posix().isascii():
        fd, tmp = tempfile.mkstemp(suffix=".pcd")
        os.close(fd)
        shutil.copy2(str(path), tmp)
        try:
            return o3d.io.read_point_cloud(tmp)
        finally:
            os.remove(tmp)
    return o3d.io.read_point_cloud(str(path))

def write_pcd(pcd: o3d.geometry.PointCloud, path: Path):
    if os.name == "nt" and not path.as_posix().isascii():
        fd, tmp = tempfile.mkstemp(suffix=".pcd")
        os.close(fd)
        try:
            o3d.io.write_point_cloud(tmp, pcd)
            shutil.copy2(tmp, str(path))
        finally:
            os.remove(tmp)
    else:
        o3d.io.write_point_cloud(str(path), pcd)
```

Only activates on Windows + non-ASCII path — no overhead otherwise.

> **适用格式**：不只是 `.pcd`，同样适用于 `.ply`、`.xyz`、`.bin`（所有经 open3d C++ 后端读写的格式）。只需把 `suffix=".pcd"` 改成对应后缀。

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| read returns empty (no error) | open3d silently fails on bad path | Use tempfile detour |
| write produces corrupted file | Same root cause on write | write also needs tempfile |
| multiprocessing tempfile conflict | Multiple processes same tmp | `mkstemp` generates unique path per call — safe |
