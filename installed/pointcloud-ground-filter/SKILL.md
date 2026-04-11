---
name: pointcloud-ground-filter
description: Validate and compare point cloud ground segmentation methods (CSF, RANSAC) with Open3D visualization, and run DBSCAN clustering on merged non-ground frames. Use this when evaluating ground filtering algorithms on UAV or roadside LiDAR data, or when needing to visually inspect segmentation quality or cluster scene objects.
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

## Merged scene clustering (cluster_merged.py)

Script: `src/visualization/cluster_merged.py`

**DBSCAN parameter tuning (3 parameters are coupled):**

| Parameter | Role | UAV 150m recommended |
|-----------|------|----------------------|
| `voxel` | Downsample grid size (m) | 0.3m |
| `eps` | Neighbourhood radius (m) | 1.0m (2.0m causes building/vegetation merge) |
| `min_pts` | Min neighbours to form cluster | 5 (vehicles are sparse at 150m) |

**Validated result (400 non-ground frames, voxel=0.3, eps=2.0, min_pts=5):**
- 240 clusters, noise 0% (eps too large), median cluster size 41 pts
- Buildings: largest clusters (100k–310k pts), Z centroid 18–28m
- Vehicle candidates: small clusters (20–100 pts), Z centroid near ground
- Problem: eps=2.0m merges vehicles with adjacent roadside vegetation → try eps=1.0m

**Post-processing filters to separate vehicles from vegetation:**
- Bounding box: length 3–8m, width 1.5–3m
- Z std dev: vehicles < 0.6m (flat roof), trees > 0.6m (irregular canopy)
- Aspect ratio: l/w ≥ 1.3 distinguishes elongated vehicles from round tree crowns

**Algorithm upgrade path:**
- HDBSCAN: adaptive density, handles building (dense) + vehicle (sparse) coexistence; `pip install hdbscan`; good for paper comparison experiment

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `UnicodeDecodeError` reading PCD | Chinese path on Windows | Use relative paths, run from correct working dir |
| Chinese output garbled | Windows terminal GBK | Remove emoji or set UTF-8 output at script start |
| File not found in VSCode | Wrong working directory | Run from data directory or use absolute paths |
| CSF unstable on certain frames | Too few iterations (iter=100) | Use iter=500, res=0.5 |
| Noise 0%, buildings merged into giant clusters | eps too large (2.0m) | Reduce eps to 1.0m |
| Vehicles merge with roadside vegetation | Same height range (~1m), eps too large | Reduce eps + apply shape post-filtering |
