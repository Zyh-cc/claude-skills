---
name: 3d-annotation-tool-selection
description: Use when selecting or evaluating 3D point cloud annotation tools (labelCloud, 3DBat, SUSTechPOINTS) for UAV/LiDAR datasets with KITTI format, UTM coordinates, or non-standard ry conventions. Covers ry compatibility, large coordinate precision, round-trip safety, labelCloud critical config, full keyboard shortcuts, and Ctrl+C/V source code modification.
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

---

## labelCloud Critical Config (annotations get wiped if wrong)

**Two settings that MUST be correct, or labelCloud will silently clear your annotation files:**

```
Class name : Car   (case-sensitive; Vehicle or car → loads 0 boxes → auto-save wipes file on next/prev)
Label format: kitti_untransformed   (not kitti, not kitti_camera)
```

`kitti_untransformed` = bbox coords stored directly in LiDAR frame, no calibration transform needed.

Config locations: `resources/_classes.json` in the labelCloud package, and the Settings UI Label Format field.

## labelCloud Full Keyboard Shortcuts (verified from controller.py source)

| Action | Key(s) |
|--------|--------|
| **Translate bbox** | W/S (Y), A/D (X), Q/E (Z up/down) |
| **Rotate bbox** | Z/X (Z-axis CCW/CW), C/V (Y-axis), B/N (X-axis) |
| **Scale bbox** | I/O (length), K/L (width), , /. (height) |
| **Select bbox** | T/↑ (prev), G/↓ (next), 1~9 (direct) |
| **Navigate files** | F/→ (next, auto-saves), R/← (prev) |
| **Delete bbox** | Delete |
| **Save** | Ctrl+S |
| **Copy/Paste** | Ctrl+C / Ctrl+V *(requires source mod below)* |

> For UAV top-down scenes, Z-axis accuracy is low (only roof points exist). Focus on XY position (W/A/S/D) and yaw rotation (Z/X keys).

## labelCloud Source Mod: Add Ctrl+C/V Copy-Paste

Useful for dense parking lots where many boxes share the same shape.

**File**: `{env}/Lib/site-packages/labelCloud/control/controller.py`

**Step 1** — add clipboard field in `__init__`:
```python
self._clipboard_bbox = None  # for Ctrl+C / Ctrl+V duplicate
```

**Step 2** — insert BEFORE the existing `elif a0.key() == Keys.Key_C:` block in `key_press_event`:
```python
# Copy active bbox to clipboard
elif a0.key() == Keys.Key_C and self.ctrl_pressed:
    active = self.bbox_controller.get_active_bbox()
    if active is not None:
        self._clipboard_bbox = active
        logging.info("Copied bounding box to clipboard.")

# Paste clipboard bbox (duplicate with small offset)
elif a0.key() == Keys.Key_V and self.ctrl_pressed:
    if self._clipboard_bbox is not None:
        from ..model.bbox import BBox
        cx, cy, cz = self._clipboard_bbox.center
        l, w, h = self._clipboard_bbox.get_dimensions()
        new_bbox = BBox(cx + 0.5, cy, cz, l, w, h)
        new_bbox.x_rotation = self._clipboard_bbox.x_rotation
        new_bbox.y_rotation = self._clipboard_bbox.y_rotation
        new_bbox.z_rotation = self._clipboard_bbox.z_rotation
        new_bbox.classname = self._clipboard_bbox.classname
        self.bbox_controller.add_bbox(new_bbox)
        logging.info("Pasted bounding box from clipboard.")
```

**Key rule**: Ctrl+C/V blocks must come BEFORE the bare C/V blocks, and check `self.ctrl_pressed`. Otherwise Ctrl+C triggers Y-axis rotation instead.
