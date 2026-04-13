---
name: 3d-annotation-tool-selection
description: Use when selecting or evaluating 3D point cloud annotation tools (labelCloud, 3DBat, SUSTechPOINTS) for UAV/LiDAR datasets with KITTI format, UTM coordinates, or non-standard ry conventions. Covers ry compatibility, large coordinate precision, and round-trip safety.
---

## Three Must-Check Dimensions

### 1. ry Definition Compatibility
- **KITTI official**: ry = rotation around camera Y-axis (car-forward camera)
- **UAV/LiDAR practice**: ry = yaw angle in XY plane (Z-axis rotation)

| Tool | ry Interpretation | Compatible with UAV yaw? |
|------|------------------|--------------------------|
| 3D BAT | KITTI camera Y-axis | ❌ Wrong direction |
| labelCloud | Z-axis CCW yaw | ✅ Matches PCA yaw |
| SUSTechPOINTS | Untested | ⚠️ Verify first |

### 2. Large Coordinate Precision (UTM ~100万量级)
| Backend | Float Precision | Error at UTM scale | Safe? |
|---------|----------------|-------------------|-------|
| WebGL (browser) | float32 | ~0.06m | ❌ |
| Python/OpenGL | float64 | <1μm | ✅ |

**3D BAT is WebGL → reject immediately for UTM coordinates.**

### 3. Round-trip Safety (save → reload → same coordinates?)
- **labelCloud**: no centering, raw UTM preserved ✅
- **SUSTechPOINTS**: auto-centers, reverse transform unverified ⚠️

## Recommended: labelCloud

```bash
pip install labelCloud
labelCloud
# Settings: LABEL_FORMAT = KITTI
```

Write point clouds as ASCII PCD (preserves float64, no precision loss):
```python
o3d.io.write_point_cloud(str(out_path), pcd, write_ascii=True)
```

## Pitfalls

| Pitfall | Cause | Fix |
|---------|-------|-----|
| 3DBat bbox visually offset from cloud | WebGL float32 at UTM scale | Use Python-based tool |
| 3DBat bbox rotated wrong | ry interpreted as camera Y-axis | Use labelCloud |
| 3DBat image view useless | No real calib, only identity matrix | Feature unavailable without real calib |
