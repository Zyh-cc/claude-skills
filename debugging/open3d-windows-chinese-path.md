---
领域: debugging
版本: v1.0
最后更新: 2026-04-11
适用工具: Claude Code
---

# open3d 在 Windows 中文路径下读写 PCD 报错，用 tempfile 绕过

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-11 | 初始版本，来源：AeroGround-Dataset 本地脚本调试 |

## 问题场景

在 Windows 上，项目路径包含中文（如 `D:\项目\数据\点云\`），调用 open3d 的
`read_point_cloud` 或 `write_point_cloud` 时报编码错误或静默返回空点云。

**根因**：open3d 的 C++ 后端在 Windows 上把 UTF-8 路径当 GBK 解码，中文字符解码失败。

## 解决方案

### 推荐方案：读写时走 tempfile 中转

```python
import os, shutil, tempfile
from pathlib import Path
import open3d as o3d

def read_pcd(path: Path) -> o3d.geometry.PointCloud:
    """读取 PCD，自动处理 Windows 中文路径。"""
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
    """写入 PCD，自动处理 Windows 中文路径。"""
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

**触发条件**：`os.name == "nt"` 且路径含非 ASCII 字符，否则直接走原始路径，不引入额外开销。

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 读返回空点云（无报错） | open3d 静默失败，路径解码错误但不抛异常 | 加 tempfile 绕过 |
| 写入后文件损坏 | write 也同样有中文路径问题 | write 也需要 tempfile 中转 |
| multiprocessing 下 tempfile 冲突 | 多进程同时用同一 tmp 路径 | `mkstemp` 每次生成唯一路径，无冲突 |

## 相关经验

- 本绕过已集成在 `src/preprocessing/ground_filter_local_test.py` 和
  `src/annotation/cluster_merged_scene.py`（AeroGround-Dataset 项目）
