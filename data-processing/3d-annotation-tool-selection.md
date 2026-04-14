---
领域: data-processing
版本: v2.0
最后更新: 2026-04-14
适用工具: Claude Code
---

# UAV/LiDAR 点云标注工具选型：三个必查维度

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-13 | 初始版本，基于 AeroGround-Dataset 3DBat→labelCloud 决策过程 |
| v2.0 | 2026-04-14 | 新增 labelCloud 关键配置项、完整快捷键表、源码改造方法 |

## 问题场景

为 UAV 俯视 LiDAR 点云选择人工标注工具时，常见工具（3D BAT、labelCloud、SUSTechPOINTS）都声称支持 KITTI 格式，但坐标系和精度上存在隐藏陷阱，直接导致标注框对不上点云或保存后坐标偏移。

典型情况：
- 点云坐标为 UTM 绝对坐标（cx≈657000, cy≈3549000）
- ry 是 UAV 俯视视角下 XY 平面的 PCA 方位角（绕 Z 轴偏航角）
- 无相机标定文件（纯 LiDAR 标注）

## 三个必查维度

### 1. ry 定义是否兼容

**KITTI 官方**：ry 是绕相机坐标系 Y 轴旋转（车载摄像头朝前，Y 轴朝下）。  
**UAV/LiDAR 实践**：ry 通常是绕 Z 轴的偏航角（XY 平面内方位角）。

| 工具 | ry 解释 | 兼容 UAV 方位角？ |
|------|--------|-----------------|
| 3D BAT | KITTI 相机 Y 轴旋转 | ❌ 方向全错 |
| labelCloud | 绕 Z 轴逆时针偏航角 | ✅ 完全一致 |
| SUSTechPOINTS | 需实测 | ⚠️ 不确定 |

验证方法：导入一个已知朝向的框，看工具里显示的方向是否正确。

### 2. 大坐标精度是否安全

UTM 坐标值（~100万量级）在不同渲染后端下精度差异显著：

| 后端 | 浮点精度 | UTM坐标下误差 | 是否安全 |
|------|---------|-------------|---------|
| WebGL（浏览器） | float32 | ~0.06m | ❌ bbox 明显偏移 |
| Python/OpenGL | float64 | <1μm | ✅ |

**3D BAT 是 WebGL，直接淘汰**。Python 桌面工具（labelCloud、SUSTechPOINTS）均安全。

### 3. 保存时坐标是否正确写回（round-trip）

工具可能在加载时做中心化（把点云移到原点），但保存标注时能否正确反算回原始坐标：
- **labelCloud**：不做中心化，直接用原始坐标，保存时原样写回 ✅
- **SUSTechPOINTS**：自动中心化，保存反算逻辑未经验证 ⚠️

验证方法：导入→不做任何修改→保存→对比原文件 cx/cy/cz 是否一致。

## 解决方案

### 推荐方案：labelCloud（UAV LiDAR 场景）

```bash
pip install labelCloud
labelCloud
```

配置（Settings 界面或 `config.ini`）：
```ini
LABEL_FORMAT = KITTI
POINT_CLOUD_FOLDER = /path/to/point_clouds   # ASCII PCD 文件
LABEL_FOLDER = /path/to/labels               # KITTI .txt 文件
```

**数据准备**：点云保存为 ASCII PCD（`write_ascii=True`），保留原始 UTM 坐标，不做中心化。

```python
pcd.points = o3d.utility.Vector3dVector(pts.astype(np.float64))
o3d.io.write_point_cloud(str(out_path), pcd, write_ascii=True)
```

### 不推荐：3D BAT

- WebGL float32 精度不足
- ry 定义与 UAV 方位角不兼容
- 需要相机标定文件（纯 LiDAR 场景只能用虚拟矩阵，图像视图失效）

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 3D BAT 中 bbox 与点云明显偏移 | WebGL float32 在 UTM 坐标量级下精度只有 ~0.06m | 换 Python 桌面工具 |
| 3D BAT 中 bbox 方向全部转错 | ry 按 KITTI 相机 Y 轴解释，而我们存的是 Z 轴偏航角 | 换 labelCloud |
| 3D BAT 图像投影视图无意义 | 无真实相机标定，只能用单位矩阵虚拟 calib | 此功能不可用，3D BAT 最大优势丧失 |

## 相关经验

- [点云地面滤除验证.md](点云地面滤除验证.md) — CSF 参数选择，预标注的上游步骤

---

## labelCloud 关键配置（踩坑后补充）

### 必须正确配置的两项，否则标注文件会被清空

```
类别名称：Car（大小写敏感，不能用 Vehicle 或其他）
标注格式：kitti_untransformed（不是 kitti，不是 kitti_camera）
```

原因：labelCloud 加载时按类别名匹配，名称不对则加载 0 框；翻到下一个文件时自动保存会把 0 框写回文件，**永久清空原标注**。`kitti_untransformed` 表示 bbox 坐标直接存 LiDAR 坐标系，不需要标定文件变换。

配置位置：labelCloud 安装目录 `resources/_classes.json` 和 `Settings` 界面中的 Label Format。

### 完整快捷键表（来自 controller.py 源码，2026-04-14 核实）

| 操作 | 键 |
|------|----|
| **平移 bbox** | W/S/A/D（XY），Q/E（Z轴上/下） |
| **旋转 bbox** | Z/X（绕Z逆/顺时针），C/V（绕Y），B/N（绕X） |
| **缩放 bbox** | I/O（长度），K/L（宽度），,/.（高度） |
| **选择 bbox** | T/↑（上一个），G/↓（下一个），1~9（直接选第N个） |
| **导航** | F/→（下一文件），R/←（上一文件） |
| **删除** | Delete |
| **保存** | Ctrl+S |
| **复制粘贴**（需源码改造，见下） | Ctrl+C / Ctrl+V |

> ⚠️ UAV 俯视场景中 Z 轴精度意义不大（只有顶面点），标注时重点调 XY 位置（W/A/S/D）和旋转角（Z/X键）。

### labelCloud 源码改造：新增 Ctrl+C/V 复制粘贴

场景：密集停车场大量形状相同的停车位框，复制已有框再平移效率远高于逐个新建。

修改文件：`{Python环境}/Lib/site-packages/labelCloud/control/controller.py`

在 `__init__` 中添加剪贴板字段：
```python
self._clipboard_bbox = None  # for Ctrl+C / Ctrl+V duplicate
```

在 `key_press_event` 中，**在现有 `elif a0.key() == Keys.Key_C:` 之前**插入 Ctrl+C/V 判断：
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

注意：`ctrl_pressed` 是 controller 的已有字段，在 `Key_Control` 按下时置为 True。Ctrl+C/V 必须在独立的 `elif` 块中，且放在裸 C/V 键处理之前，否则 Ctrl+C 会触发 Y 轴旋转。
