---
name: academic-plot
description: Use when user wants to plot academic figures, reproduce paper figures, visualize sensor/monitoring time-series data, or asks about 画图/成图/出图效果/学术图/复现论文图/MATLAB绘图/Python画图/matplotlib/传感器数据可视化
---

# 学术图绘制（MATLAB / Python）

## 工作流（接到任务时按顺序执行）

**Step 1 — 探测数据结构**（不能跳过）

MATLAB timetable：
```matlab
loaded = load('yourfile.mat');
fnames = fieldnames(loaded);
tt = loaded.(fnames{1});
fprintf('类型:%s | 行:%d | 列:%s\n', class(tt), height(tt), ...
    strjoin(tt.Properties.VariableNames,', '));
if istimetable(tt)
    fprintf('时间: %s ~ %s\n', string(tt.Properties.RowTimes(1)), string(tt.Properties.RowTimes(end)));
end
disp(tt(1:3,:));
```

Python：
```python
import scipy.io, pandas as pd
mat = scipy.io.loadmat('file.mat')
print([k for k in mat.keys() if not k.startswith('_')])
df = pd.read_csv('file.csv', parse_dates=['time'])
print(df.dtypes, df.head(3))
```

**Step 1.5 — 若用户提供参考图，先分析图的元素**（有参考图时必做）

| 要素 | 观察内容 | 对应代码参数 |
|------|---------|------------|
| 布局 | 几行几列？行/列各代表什么？ | `subplot(nRows, nCols, ...)` |
| 线条 | 几条线？颜色？粗细？ | `Color`, `LineWidth` |
| 标注 | 子图内有无文字？位置？ | `text(..., 'Units','normalized')` |
| x 轴 | 时间范围？刻度格式？几个刻度？ | `XTick`, `XTickLabel` |
| y 轴 | 每行 y 标签？范围？ | `ylabel`, `ylim` |
| 数据 | 线是否在 0 附近振荡？ | → 需要去均值预处理 |

**Step 2 — 确认需求**（若不明确，问用户）
- 几行几列？每列哪个传感器？时间范围？x 轴刻度粒度？
- 几条线？颜色约定？有无文字标注？
- MATLAB 还是 Python？是否需要符合顶刊投稿规范？

**Step 3 — 套用模板写代码**（见下方各模块；投稿图参照文末附录）

**Step 4 — 导出**：MATLAB 用 `print(gcf,...)`，Python 用 `savefig`

---

## 代码模板

### 多子图布局

**MATLAB**
```matlab
fig = figure('Color','w','Position',[100 100 1400 520]);
axAll = gobjects(nRows, nCols);
for row = 1:nRows
    for col = 1:nCols
        ax = subplot(nRows, nCols, (row-1)*nCols + col);
        axAll(row, col) = ax;
        plot(ax, t, v, 'Color',[0.55 0.55 0.55], 'LineWidth',0.6);
        if col == 1,      ylabel(ax, 'Y标签', 'FontSize',8); end
        if row == nRows,  xlabel(ax, 'Date / Month-Day', 'FontSize',8); end
        if row == 1,      title(ax, colLabels{col}, 'FontWeight','normal'); end
        box(ax,'on');  ax.TickDir='in';  ax.FontSize=8;  ax.LineWidth=0.8;
    end
end
```

**Python**（普通场景）
```python
fig, axes = plt.subplots(nRows, nCols, figsize=(14, 5.2), constrained_layout=True)
fig.patch.set_facecolor('white')
for row in range(nRows):
    for col in range(nCols):
        ax = axes[row][col]
        ax.plot(t, v, color='#8C8C8C', linewidth=0.6)
        ax.spines['top'].set_visible(False); ax.spines['right'].set_visible(False)
        ax.tick_params(direction='in', length=3, width=0.8)
        if col == 0:       ax.set_ylabel('Y标签', fontsize=8)
        if row == nRows-1: ax.set_xlabel('Date / Month-Day', fontsize=8)
        if row == 0:       ax.set_title(colLabels[col], fontsize=9, fontweight='normal')
```

### 子图内文字标注（不遮数据）

```matlab  % MATLAB
text(ax, 0.04, 0.08, sprintf('Peak\n%.2f°', val), ...
    'Units','normalized', 'FontSize',7.5, 'VerticalAlignment','bottom');
```
```python  # Python
ax.text(0.04, 0.08, f'Peak\n{val:.2f}°', transform=ax.transAxes,
        fontsize=7.5, va='bottom')
```

### x 轴时间刻度

```matlab  % MATLAB — 跨年必须手动设标签
ax.XTick = tickTimes;
ax.XTickLabel = {'10-01','11-01','12-01','01-01'};  % ✅ 正确
% xtickformat(ax,'MM-dd');  ← ❌ 跨年会显示"2022/1"
```
```python  # Python
import matplotlib.dates as mdates
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m-%d'))
```

### 传感器数据预处理

```matlab  % MATLAB
v = tt.column - mean(tt.column,'omitnan');              % 去均值
v(abs(v-mean(v,'omitnan')) > 3*std(v,'omitnan')) = NaN; % 去异常值3σ
```
```python  # Python
v = df['col'] - df['col'].mean()                         # 去均值
v[abs(v - v.mean()) > 3*v.std()] = float('nan')          # 去异常值3σ
```

### 导出

```matlab  % MATLAB ✅ 推荐（句柄稳定）
print(gcf, 'output', '-dpng', '-r300');
% ❌ 勿用 exportgraphics 连续两次，第二次句柄失效
```
```python  # Python 投稿
fig.savefig('figure.pdf', bbox_inches='tight', facecolor='white')       # 矢量投稿
fig.savefig('figure.png', dpi=300, bbox_inches='tight', facecolor='white')  # 预览
```

---

## 踩坑速查

| 现象 | 工具 | 原因 | 解决 |
|------|------|------|------|
| exportgraphics 第二行报"无效图形对象" | MATLAB | PDF导出后句柄变化 | 改用 `print(gcf,...)` |
| x 轴跨年显示"2022/1" | MATLAB | xtickformat 加年份 | 手动设 `XTickLabel` |
| 文字标注遮住数据 | MATLAB | 数据坐标定位 | 用 `Units: normalized` |
| 两条位移线完全分离 | 通用 | 原始数据有静态偏置 | 绘图前各自去均值 |
| 多子图顶部标题被遮 | MATLAB | annotation y 不够高 | y 从 0.95 改到 0.97+ |
| 不知道 mat 文件变量名/列名 | MATLAB | — | 先跑 Step 1 probe 脚本 |
| Python 图字体模糊 | Python | dpi 不足 | `savefig(..., dpi=300)` |
| tight_layout 裁掉标题 | Python | 布局自动计算 | 改用 `constrained_layout=True` |

## 图不对时逐项排查

- [ ] **布局**：行列数、标题位置是否一致？
- [ ] **数据范围**：y 轴不在 0 附近 → 检查是否需要去均值
- [ ] **异常值**：有孤立尖刺 → 加 3σ 过滤
- [ ] **颜色/线宽**：是否匹配参考图？
- [ ] **标注位置**：遮住数据 → 改用 `Units: normalized`
- [ ] **x 轴刻度**：格式、数量、跨年问题？
- [ ] **导出分辨率**：PNG 是否 300 dpi？

---

## 附录：顶刊投稿规范（Nature / Science / IEEE）

> 仅在用户明确要求"投稿格式"或"顶刊规范"时使用。

### 规范速查

| 参数 | 单栏 | 双栏 | 说明 |
|------|------|------|------|
| 图宽 | 90mm (3.54in) | 180mm (7.09in) | `figsize=(90/25.4, h/25.4)` |
| 最大高度 | — | 170mm | Nature 限制 |
| 字体 | Arial / Helvetica | ← 同 | 禁用宋体/楷体 |
| 标签字号 | 6pt | ← 同 | tick 5.5pt，面板标签 7pt bold |
| 线宽 | 0.6–1.0pt | ← 同 | 密集时间序列用 0.6 |
| 边框 | 去顶/右 (open) | ← 同 | 更现代，多数顶刊偏好 |
| 颜色 | Okabe-Ito | ← 同 | 色盲友好 |
| 面板标签 | **(a)(b)(c)** | ← 同 | 小写加粗，左上角外侧 |
| 导出 | PDF + PNG 300dpi | ← 同 | PDF 矢量投稿 |

### Python 顶刊全局设置（脚本顶部）

```python
import matplotlib as mpl
mpl.rcParams.update({
    'font.family': 'sans-serif', 'font.sans-serif': ['Arial','DejaVu Sans'],
    'font.size': 6, 'axes.linewidth': 0.8,
    'axes.labelsize': 6, 'xtick.labelsize': 5.5, 'ytick.labelsize': 5.5,
    'xtick.major.size': 3, 'ytick.major.size': 3,
    'xtick.major.width': 0.8, 'ytick.major.width': 0.8,
    'xtick.direction': 'in', 'ytick.direction': 'in',
    'legend.fontsize': 5.5, 'legend.frameon': False,
    'figure.facecolor': 'white', 'pdf.fonttype': 42, 'ps.fonttype': 42,
})
```

### Okabe-Ito 色板

```python
OI_BLUE='#0072B2'; OI_VERMILION='#D55E00'; OI_GREEN='#009E73'
OI_ORANGE='#E69F00'; OI_SKY='#56B4E9'; OI_GRAY='#8C8C8C'
# 禁止：纯红+纯绿组合（红绿色盲无法区分）
```

### Open Style 轴 + 面板标签

```python
# Open style
ax.spines['top'].set_visible(False); ax.spines['right'].set_visible(False)
ax.tick_params(direction='in', length=3, width=0.8, top=False, right=False)
# 面板标签
ax.text(-0.15, 1.08, '(a)', transform=ax.transAxes,
        fontsize=7, fontweight='bold', va='top', ha='left')
```

---
*v3.0 · 2026-04-16 · 结构重组：工作流置顶，顶刊规范移附录，合并冗余样式*
