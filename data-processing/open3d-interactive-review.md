# Open3D 交互审核：Ray-OBB 拾取 + FP/FN 标记 + 日志输出

**版本**：v1.2 — 2026-04-13  
**项目**：AeroGround-Dataset `vis_preannot_window.py`  
**环境**：Python 3.10，Open3D 0.19.0

---

## 适用场景

在 Open3D `VisualizerWithKeyCallback` 窗口中为 3D bbox 添加交互审核能力：
- 鼠标单击拾取最近的 bbox，打印诊断信息
- 双击切换 FP/FN 标记，实时刷新颜色
- 窗口间切换保留标记状态
- 退出时写出结构化 JSON 日志

---

## 核心 API

### Open3D 0.19 鼠标回调限制（重要）

`register_mouse_move_callback` 和 `register_mouse_button_callback` 在 Open3D 0.19
中**完全替换** GLFW 底层回调，无论返回 `True` 还是 `False`，
`Visualizer::MouseMoveCallback / MouseButtonCallback`（维护拖拽状态）都不再被调用，
导致旋转/平移永久失效。**两者都不能注册。**

### 正确方案：animation_callback + Win32 轮询

```python
import ctypes, time

state['lbtn_was_down'] = False

class _PT(ctypes.Structure):
    _fields_ = [("x", ctypes.c_long), ("y", ctypes.c_long)]

def _cursor_in_window():
    pt = _PT()
    ctypes.windll.user32.GetCursorPos(ctypes.byref(pt))
    hwnd = ctypes.windll.user32.GetForegroundWindow()
    if hwnd:
        ctypes.windll.user32.ScreenToClient(hwnd, ctypes.byref(pt))
    return float(pt.x), float(pt.y)

def _on_animation(v) -> bool:
    lbtn_down = bool(ctypes.windll.user32.GetAsyncKeyState(0x01) & 0x8000)
    was_down  = state['lbtn_was_down']
    state['lbtn_was_down'] = lbtn_down
    if not (lbtn_down and not was_down):   # 只处理按下边沿
        return False
    mx, my = _cursor_in_window()
    b = find_clicked_bbox(v, mx, my, ...)
    ...
    return False

vis.register_animation_callback(_on_animation)
# 不调用 register_mouse_button_callback / register_mouse_move_callback
```

`register_animation_callback` 定义在基类 `Visualizer` 上，不替换任何 GLFW 处理器，
不影响默认的拖拽行为。

### 射线生成（像素 → 世界坐标）

```python
def ray_from_pixel(vis, x, y):
    vc = vis.get_view_control()
    params = vc.convert_to_pinhole_camera_parameters()
    K = np.array(params.intrinsic.intrinsic_matrix)   # 3×3
    E = np.array(params.extrinsic)                    # 4×4 世界→相机

    fx, fy = K[0,0], K[1,1]
    cx, cy = K[0,2], K[1,2]
    d_cam  = np.array([(x-cx)/fx, (y-cy)/fy, 1.0])
    d_cam /= np.linalg.norm(d_cam)

    R_cw     = E[:3,:3]
    t_cw     = E[:3, 3]
    cam_orig = -R_cw.T @ t_cw      # 相机中心（世界坐标）
    ray_dir  = R_cw.T @ d_cam       # 射线方向（R_cw 正交，norm 不变）
    return cam_orig, ray_dir
```

### Ray-OBB Slab 求交

```python
def ray_obb_intersect(origin, direction, center, R, extent):
    """
    R: 3×3，列向量为 OBB 局部坐标轴（与 make_bbox_geometry 的 R 一致）
    extent: [l, w, h]
    返回 t（>=0）或 None
    """
    local_o = R.T @ (origin - center)
    local_d = R.T @ direction
    half    = extent / 2.0

    t_min, t_max = -np.inf, np.inf
    for i in range(3):
        if abs(local_d[i]) < 1e-9:
            # Strict >: origin exactly on face counts as inside slab (intentional).
            if abs(local_o[i]) > half[i]:
                return None
        else:
            t1 = (-half[i] - local_o[i]) / local_d[i]
            t2 = ( half[i] - local_o[i]) / local_d[i]
            if t1 > t2: t1, t2 = t2, t1
            t_min = max(t_min, t1)
            t_max = min(t_max, t2)
            if t_min > t_max:
                return None

    if t_max < 0:
        return None
    return float(t_min if t_min >= 0 else t_max)
```

**注意事项：**
- `t_min < 0 and t_max >= 0`：射线起点在 box 内，返回 `t_max`（出口距离）
- `R` 的列向量须与渲染用的旋转矩阵一致，否则拾取和显示不对齐

---

## 双击检测

```python
DOUBLE_CLICK_DT  = 0.4   # 秒
DOUBLE_CLICK_PIX = 10    # 像素最大偏移

now   = time.time()
dt    = now - state['last_click_time']
dxy   = max(abs(x - state['last_click_xy'][0]),
            abs(y - state['last_click_xy'][1]))
is_dbl = dt < DOUBLE_CLICK_DT and dxy < DOUBLE_CLICK_PIX
state['last_click_time'] = now          # 必须在 check 之后更新
state['last_click_xy']   = (x, y)
```

**关键顺序**：先计算 `dt/dxy`，再更新 `last_click_time/xy`，否则双击永远无法触发。

---

## Window Cache 模式（跨窗口保留标记）

```python
# state 中维护单一缓存，首次访问加载，切回时复用
if wid not in state['window_cache']:
    pts      = load_point_cloud(...)
    accepted, rejected = load_detail_json(wid)
    state['window_cache'][wid] = {
        'pts': pts, 'accepted': accepted, 'rejected': rejected
    }
# _marked 标志直接修改 cache 内的 dict（in-place），不需要同步
b['_marked'] = not b['_marked']
reload_scene(vis, state, wid)
```

---

## 审核日志结构

```json
{
  "session_start": "2026-04-13T10:00:00",
  "session_end":   "2026-04-13T10:30:00",
  "summary": { "windows_reviewed": 5, "total_FP": 3, "total_FN": 2 },
  "windows": {
    "img_0013": {
      "false_positives": [
        { "bbox_idx": 0, "l": 3.21, "confidence": 0.724, ... }
      ],
      "false_negatives": [
        { "rejected_type": "rejected_shape", "l": 5.12, ... }
      ]
    }
  }
}
```

日志路径使用秒级时间戳 + collision guard：
```python
log_path = ANNOT_DIR / f"review_log_{now.strftime('%Y%m%d_%H%M%S')}.json"
counter = 1
while log_path.exists():
    log_path = ANNOT_DIR / f"review_log_{now.strftime('%Y%m%d_%H%M%S')}_{counter}.json"
    counter += 1
```

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| 回退条件误判 | `if not accepted` 无法区分"无 detail JSON"和"全部拒绝" | 改为直接检查 `load_detail_json` 返回值：`if not accepted and not rejected` |
| rejected idx 碰撞 | `for rej_type` 循环内用 `enumerate()` 每次从 0 开始 | 用跨两个 sub-list 的全局计数器 `rej_idx` |
| DETAIL_DIR 未同步 | `--annot_dir` 只更新 `ANNOT_DIR`，`DETAIL_DIR` 仍指向旧路径 | `global ANNOT_DIR, DETAIL_DIR` 一起更新 |
| 双击后第二次 norm 冗余 | `R_cw.T` 正交，norm 不变 | 只保留第一次 normalize，删除 `ray_dir /= norm` |
| **register_mouse_move_callback 或 register_mouse_button_callback 导致拖拽失效** | Open3D 0.19 中两者都完全替换 GLFW 回调，`Visualizer::MouseMoveCallback/MouseButtonCallback` 不再被调用，拖拽状态无法维护 | **两者都不注册**；改用 `register_animation_callback` + Win32 `GetAsyncKeyState` 轮询左键边沿 |

---

## 测试要点（pytest）

```python
# 命中：t == approx(9.0)（从 z=-10 射向 z=0 处单位 box，近面 z=-1）
# 未命中：偏离 box，t is None
# 背后：origin 在 box 后方，t is None
# 旋转 OBB：绕 Z 旋转不影响 Z slab，t 仍 == 9.0
# 内部起点：t_max 分支，返回出口距离（不是 None）
```
