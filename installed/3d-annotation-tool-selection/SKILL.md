---
name: 3d-annotation-tool-selection
description: labelCloud 操作手册：UAV/LiDAR点云标注配置、快捷键、Ctrl+C/V源码改造，以及工具选型依据（为何放弃3DBat）。Triggers on: "labelCloud", "标注配置", "点云标注", "标注快捷键", "Ctrl+C复制框", "3D annotation", "kitti_untransformed", "ry定义", "UTM坐标精度"
---

## 启动前必检（否则会静默清空标注文件）

**两个设置必须正确，错一个 labelCloud 就会在翻帧时自动保存空文件：**

```
Class name  : Car            ← 区分大小写，不能写 Vehicle / car / CAR
Label format: kitti_untransformed   ← 不能选 kitti 或 kitti_camera
```

配置位置：
- `resources/_classes.json`（labelCloud 安装包内）
- Settings UI → Label Format 下拉框

`kitti_untransformed` = bbox坐标直接存在LiDAR坐标系，无需标定变换。

---

## 快捷键（从 controller.py 源码验证）

| 操作 | 按键 |
|------|------|
| **平移框** | W/S（Y轴），A/D（X轴），Q/E（Z轴升降） |
| **旋转框** | Z/X（Z轴逆/顺时针），C/V（Y轴），B/N（X轴） |
| **缩放框** | I/O（长），K/L（宽），,/.（高） |
| **选择框** | T/↑（上一个），G/↓（下一个），1~9（直选） |
| **翻帧** | F/→（下一帧，自动保存），R/←（上一帧） |
| **删除框** | Delete |
| **保存** | Ctrl+S |
| **复制/粘贴** | Ctrl+C / Ctrl+V（需源码改造，见下） |

> UAV俯视场景：Z轴精度低（只有屋顶点），重点调XY位置（W/A/S/D）和偏航角（Z/X）。

---

## Ctrl+C/V 源码改造（停车场等密集场景必备）

**文件**：`{env}/Lib/site-packages/labelCloud/control/controller.py`

**Step 1**：在 `__init__` 加剪贴板字段：
```python
self._clipboard_bbox = None
```

**Step 2**：在 `key_press_event` 中，**在** 裸 `Key_C` 块**之前**插入：
```python
elif a0.key() == Keys.Key_C and self.ctrl_pressed:
    active = self.bbox_controller.get_active_bbox()
    if active is not None:
        self._clipboard_bbox = active

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
```

**关键**：Ctrl+C/V 块必须在裸 C/V 块**之前**，否则 Ctrl+C 会触发Y轴旋转。

---

## 为何不用其他工具（选型依据）

| 工具 | 放弃原因 |
|------|---------|
| **3D BAT** | WebGL float32精度在UTM坐标（~100万量级）下误差0.06m；ry定义为相机Y轴，与UAV偏航角不兼容 |
| **SUSTechPOINTS** | 自动中心化坐标，反变换未验证，round-trip安全性未知 |

**labelCloud 的优势**：ry = Z轴逆时针偏航角（与PCA方位角一致），float64坐标，`kitti_untransformed`格式直存LiDAR系。
