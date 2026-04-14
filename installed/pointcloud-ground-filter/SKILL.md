---
name: pointcloud-ground-filter
description: UAV LiDAR 点云处理流水线参考（AeroGround/湖北数据）：CSF地面过滤、图像锚定窗口预标注、HDBSCAN聚类、预标注审核工作流。Triggers on: "地面过滤", "CSF", "预标注", "HDBSCAN", "审核框", "FP/FN", "labelCloud", "pointcloud pipeline", "点云流水线"
---

## 数据特性（必读）

🔴 **湖北数据 = 重复扫描（V-FOV 3°）**：每帧只有横截面，单帧无法聚类。
→ 必须合并 ±50帧 图像锚定窗口，再做HDBSCAN。

🟢 **正式采集（双龙大道）= 非重复扫描（V-FOV 75°）**：单帧覆盖200m×200m，可逐帧处理。

---

## 已确定参数（不要改）

| 步骤 | 参数/脚本 | 状态 |
|------|-----------|------|
| CSF地面过滤 | `cloth_resolution=0.5, iterations=500`，`3_ground_filter_parallel.py`，NUM_WORKERS=16 | ✅ 4060帧完成 |
| 图像锚定窗口 | ±50帧合并，锚点 img_0011~img_0215 | ✅ 200窗口完成 |
| HDBSCAN聚类 | 默认参数 + 2D PCA OBB + 形状过滤 → KITTI .txt | ✅ 9955框完成 |
| 形状过滤 | 长 3–8m，宽 1.5–3m，Z std < 0.6m（车）/ > 0.6m（树），长宽比 l/w ≥ 1.3 | ✅ 已应用 |

---

## 当前工作：预标注审核

### Step 1：逐窗口审核（标记FP/FN）

```bash
python vis_preannot_window.py --all
```

- 双击框 → 标记 FP（误检）
- 键盘标记 FN（漏检，从 detail JSON rejected 追加）
- Q 保存 → 生成 review log：`img_XXXX_N.json`

### Step 2：应用修正

```bash
python apply_review.py --gui
```

选择 review log → 预览修正 → 执行

- FP 删除：按坐标匹配（tol=0.01m）
- FN 追加：从 detail JSON 的 rejected_shape/size 列表还原

### Step 3：确认修正

重新运行 `vis_preannot_window.py` 对应窗口，目视确认无误。

### Review log 命名规则

| 场景 | 命名 |
|------|------|
| 单窗口 | `img_XXXX_N.json` |
| 多窗口合并 | `img_XXXX_YYYY_N.json` |

---

## 审核后：labelCloud 人工精调

```bash
python src/utils/prepare_labelcloud.py
# 输出到 labelcloud_data/point_clouds/ + labels/
labelCloud
```

**关键配置（错了会清空标注）：**
```
Class name : Car          （区分大小写，不能写 Vehicle 或 car）
Label format: kitti_untransformed
```

---

## 未来：双龙大道正式数据流水线

正式采集后用逐帧方案（非重复扫描，单帧密度足够）：

```bash
python pre_annotate_dbscan.py   # 逐帧DBSCAN，不需要窗口合并
```

---

## Pitfalls

| 问题 | 原因 | 解决 |
|------|------|------|
| CSF某些帧漏分 | iter=100（精简参数） | 必须用 iter=500 |
| labelCloud加载0个框后自动保存→清空文件 | Class name大小写不对 | 严格用 `Car` |
| apply_review FP删不掉 | 坐标匹配tol太小 | 确认tol=0.01m，检查KITTI txt精度 |
| 窗口合并帧数不够 | 飞行边缘帧±50超出范围 | 自动截断到有效范围，正常 |
