---
name: academic-plot
description: Use when user wants to plot academic figures, reproduce paper figures, visualize sensor/monitoring time-series data, or asks about 画图/成图/出图效果/学术图/复现论文图/MATLAB绘图/Python画图/matplotlib/传感器数据可视化
---

# 学术图绘制（MATLAB / Python）

## 顶刊规范速查（Nature / Science / IEEE）

| 参数 | 单栏 | 双栏 | 说明 |
|------|------|------|------|
| 图宽 | 90mm (3.54in) | 180mm (7.09in) | `figsize=(mm(90), mm(h))` |
| 最大高度 | — | 170mm (6.69in) | Nature 限制 |
| 字体 | Arial / Helvetica | ← 同 | sans-serif，禁用宋体/楷体 |
| 标签字号 | 6pt | ← 同 | tick 5.5pt，面板标签 7-8pt bold |
| 线宽（数据） | 0.6-1.0pt | ← 同 | 时间序列密集时用 0.6 |
| 轴线/tick | 0.8pt | ← 同 | tick 内向，长 3pt |
| 边框样式 | 去顶/右边框 | ← 同 | open style（更现代）|
| 颜色 | Okabe-Ito | ← 同 | 色盲友好，见下方 |
| 面板标签 | **(a)(b)(c)** | ← 同 | 小写加粗，左上角 |
| 导出 | PDF + PNG | ← 同 | PDF 矢量投稿，PNG 预览 |
| DPI | 300（彩色）| 600（线图）| `pdf.fonttype=42` 嵌入字体 |

```python
def mm(x): return x / 25.4   # mm → inch 换算
```

## Okabe-Ito 色板（色盲友好，Nature 推荐）

```python
OI_BLUE      = '#0072B2'   # 主色，时间序列首选
OI_VERMILION = '#D55E00'   # 对比色
OI_GREEN     = '#009E73'
OI_ORANGE    = '#E69F00'
OI_SKY_BLUE  = '#56B4E9'
OI_GRAY      = '#8C8C8C'   # 背景/次要线
# 禁止：纯红+纯绿组合（红绿色盲无法区分）
```

## Python 顶刊全局设置（放在脚本最顶部）

```python
import matplotlib as mpl
mpl.rcParams.update({
    'font.family':      'sans-serif',
    'font.sans-serif':  ['Arial', 'DejaVu Sans'],
    'font.size':        6,
    'axes.linewidth':   0.8,
    'axes.labelsize':   6,
    'xtick.labelsize':  5.5,
    'ytick.labelsize':  5.5,
    'xtick.major.size': 3,
    'ytick.major.size': 3,
    'xtick.major.width':0.8,
    'ytick.major.width':0.8,
    'xtick.direction':  'in',
    'ytick.direction':  'in',
    'legend.fontsize':  5.5,
    'legend.frameon':   False,
    'figure.facecolor': 'white',
    'pdf.fonttype':     42,   # 嵌入字体，IEEE/Nature 要求
    'ps.fonttype':      42,
})
```

## Open Style 轴（去顶/右边框）

```python
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_linewidth(0.8)
ax.spines['left'].set_linewidth(0.8)
ax.tick_params(axis='both', direction='in', length=3, width=0.8,
               top=False, right=False)
```

## 面板标签 (a)(b)(c)

```python
# 每个子图左上角加面板标签
ax.text(-0.15, 1.08, '(a)', transform=ax.transAxes,
        fontsize=7, fontweight='bold', va='top', ha='left')
```

## 顶刊导出

```python
# PDF 矢量（投稿首选）+ PNG 预览
fig.savefig('figure.pdf', bbox_inches='tight', facecolor='white')
fig.savefig('figure.png', dpi=300, bbox_inches='tight', facecolor='white')
```

## 工作流（接到任务时按顺序执行）

**Step 1 — 探测数据结构**（不能跳过）

MATLAB timetable：
```matlab
loaded = load('yourfile.mat');
fnames = fieldnames(loaded);
fprintf('顶层变量: %s\n', strjoin(fnames, ', '));
tt = loaded.(fnames{1});
fprintf('类型: %s | 行数: %d\n', class(tt), height(tt));
if istimetable(tt) || istable(tt)
    fprintf('列名: %s\n', strjoin(tt.Properties.VariableNames, ', '));
    if istimetable(tt)
        fprintf('时间: %s ~ %s\n', string(tt.Properties.RowTimes(1)), string(tt.Properties.RowTimes(end)));
    end
    disp(tt(1:3,:));
end
```

Python：
```python
import scipy.io, pandas as pd
# mat 文件
mat = scipy.io.loadmat('file.mat')
print([k for k in mat.keys() if not k.startswith('_')])
# csv/feather
df = pd.read_csv('file.csv', parse_dates=['time'])
print(df.dtypes, df.head(3))
```

**Step 1.5 — 若用户提供参考图，先分析图的元素**（有参考图时必做）

读取并记录以下信息，再写代码：

| 要素 | 观察内容 | 对应代码参数 |
|------|---------|------------|
| 布局 | 几行几列？行/列各代表什么？ | `subplot(nRows, nCols, ...)` |
| 线条 | 几条线？颜色（灰/黑/橙/红）？粗细？ | `Color`, `LineWidth` |
| 标注 | 子图内有无文字框？位置（左下/右上）？ | `text(..., 'Units','normalized')` |
| x 轴 | 时间范围？刻度格式（MM-dd/yyyy）？几个刻度？ | `XTick`, `XTickLabel` |
| y 轴 | 每行 y 标签是什么？范围大致多少？ | `ylabel`, `ylim` |
| 数据 | 线是否在 0 附近振荡？（判断是否需要去均值） | 去均值预处理 |

→ 分析完再进 Step 2，不要边猜边写。

**Step 2 — 确认需求**（若不明确，问用户）
- 几行几列子图？每列对应哪个传感器/变量？
- 时间范围？x 轴刻度粒度（按天/按月/按小时）？
- 几条线？颜色约定？有无文字标注？
- 用 MATLAB 还是 Python？（看用户现有环境）

**Step 3 — 套用模板写代码**（见下方各模块）

**Step 4 — 导出**：MATLAB 用 `print`，Python 用 `savefig`

---

## 核心样式参数

### MATLAB
```matlab
grayColor   = [0.55 0.55 0.55];
orangeColor = [0.90 0.35 0.10];
box(ax,'on');  ax.TickDir='in';  ax.FontSize=8;  ax.LineWidth=0.8;
```

### Python (matplotlib)
```python
import matplotlib.pyplot as plt
import matplotlib as mpl
mpl.rcParams.update({
    'font.size': 8,
    'axes.linewidth': 0.8,
    'xtick.direction': 'in',
    'ytick.direction': 'in',
    'figure.facecolor': 'white',
})
GRAY   = '#8C8C8C'
ORANGE = '#E65A1A'
```

---

## 多子图布局

### MATLAB
```matlab
fig = figure('Color','w','Position',[100 100 1400 520]);
axAll = gobjects(nRows, nCols);
for row = 1:nRows
    for col = 1:nCols
        ax = subplot(nRows, nCols, (row-1)*nCols + col);
        axAll(row, col) = ax;
        plot(ax, t, v, 'Color', grayColor, 'LineWidth', 0.5);
        if col == 1,      ylabel(ax, 'Y 标签'); end
        if row == nRows,  xlabel(ax, 'Date / Month-Day'); end
        if row == 1,      title(ax, colLabels{col}, 'FontWeight','normal'); end
        box(ax,'on');  ax.TickDir='in';  ax.FontSize=8;
    end
end
```

### Python
```python
fig, axes = plt.subplots(nRows, nCols, figsize=(14, 5.2),
                          sharex=False, sharey=False)
fig.patch.set_facecolor('white')
for row in range(nRows):
    for col in range(nCols):
        ax = axes[row][col]
        ax.plot(t, v, color=GRAY, linewidth=0.5)
        ax.tick_params(direction='in')
        for spine in ax.spines.values(): spine.set_linewidth(0.8)
        if col == 0:       ax.set_ylabel('Y 标签', fontsize=8)
        if row == nRows-1: ax.set_xlabel('Date / Month-Day', fontsize=8)
        if row == 0:       ax.set_title(colLabels[col], fontsize=9, fontweight='normal')
plt.tight_layout()
```

---

## 子图内文字标注（不遮数据）

### MATLAB
```matlab
text(ax, 0.04, 0.08, sprintf('Maximum\nvariations\nis %.2f°', val), ...
    'Units','normalized', 'FontSize',7.5, 'VerticalAlignment','bottom');
```

### Python
```python
ax.text(0.04, 0.08, f'Maximum\nvariations\nis {val:.2f}°',
        transform=ax.transAxes, fontsize=7.5, va='bottom')
```

---

## x 轴时间刻度

### MATLAB（跨年必须手动设标签）
```matlab
% ✅ 正确
ax.XTick = tickTimes;
ax.XTickLabel = {'10-01','11-01','12-01','01-01'};
% ❌ 错误（跨年会显示"2022/1"）
xtickformat(ax, 'MM-dd');
```

### Python
```python
import matplotlib.dates as mdates
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m-%d'))
```

---

## 导出

### MATLAB
```matlab
% ✅ 推荐（句柄稳定）
print(gcf, 'output', '-dpng', '-r300');
% ❌ 避免（连续两次 exportgraphics 第二次句柄失效）
```

### Python
```python
fig.savefig('output.png', dpi=300, bbox_inches='tight',
            facecolor='white', edgecolor='none')
```

---

## 传感器数据预处理

```matlab
% MATLAB：去均值（挠度/位移数据有静态偏置）
v = tt.column - mean(tt.column, 'omitnan');
% 去异常值（3σ）
v(abs(v - mean(v,'omitnan')) > 3*std(v,'omitnan')) = NaN;
```

```python
# Python：去均值
v = df['column'] - df['column'].mean()
# 去异常值（3σ）
mu, sigma = v.mean(), v.std()
v[abs(v - mu) > 3*sigma] = float('nan')
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

## 图画出来和参考图不符时——逐项排查

用户说"不对"时，按顺序核对：

- [ ] **布局**：子图行列数、标题位置是否一致？
- [ ] **数据范围**：y 轴是否在 0 附近？若不是 → 检查是否需要去均值
- [ ] **异常值**：有孤立尖刺？→ 加 3σ 过滤
- [ ] **颜色/线宽**：线条颜色和粗细是否匹配参考图？
- [ ] **标注位置**：文字是否遮住数据？→ 改用 `Units: normalized` 固定在角落
- [ ] **x 轴刻度**：刻度格式（月/日/年）、数量是否一致？跨年问题？
- [ ] **导出分辨率**：PNG 是否 300 dpi？

---
*v2.0 · 2026-04-16 · 扩展为 MATLAB+Python 通用学术图技能*
