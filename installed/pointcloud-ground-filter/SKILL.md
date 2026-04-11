---
name: pointcloud-ground-filter
description: Validate and compare point cloud ground segmentation methods (CSF, RANSAC) with Open3D visualization. Use this when evaluating ground filtering algorithms on UAV or roadside LiDAR data, or when needing to visually inspect segmentation quality across multiple frames.
---

## Validated parameters (UAV point cloud dataset, flight altitude 150m)

| Method | Parameters | Result |
|--------|-----------|--------|
| **CSF original** | iter=500, res=0.5 | ✅ Stable, recommended |
| CSF simplified | iter=100, res=1.0 | ❌ Unstable — misses 16.7% ground on some frames |
| RANSAC + height | default | ❌ Systematic underestimate, not suitable for complex terrain |

## Local visualization setup

```bash
cd project_dir
python -m venv venv
.\venv\Scripts\activate   # Windows
pip install open3d numpy
```

Run in VSCode: `Ctrl+Shift+P` → `Python: Select Interpreter` → select `.\venv\Scripts\python.exe` → F5

## Visualization script features

- Load raw point cloud + multiple method outputs
- Keys 0/1/2/3: switch between method views
- Keys E/W: next/previous frame
- Auto-coloring: ground = brown, non-ground = green, raw = gray

## Quality check criteria

- ✅ Normal: green = vehicles/pedestrians/buildings/trees; brown = flat road surface
- ❌ Abnormal: green mixed with obvious ground points, or brown containing clear objects

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `UnicodeDecodeError` reading PCD | Chinese path on Windows | Use relative paths, run from correct working dir |
| Chinese output garbled | Windows terminal GBK | Remove emoji or set UTF-8 output at script start |
| File not found in VSCode | Wrong working directory | Run from data directory or use absolute paths |
| CSF unstable on certain frames | Too few iterations (iter=100) | Use iter=500, res=0.5 |
