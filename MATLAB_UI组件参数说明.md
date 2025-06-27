# MATLAB UI组件参数说明手册

## 1. uifigure - 主窗口组件

### 基本语法
```matlab
fig = uifigure(Name, Value, ...)
```

### 常用参数

| 参数名称 | 数据类型 | 说明 | 示例 |
|---------|---------|------|------|
| `Name` | 字符串/字符向量 | 窗口标题 | `'我的应用'` |
| `Position` | 4元素数值数组 | 窗口位置和大小 [x, y, width, height] | `[100, 100, 800, 600]` |
| `Resize` | `'on'`/`'off'` | 是否允许调整窗口大小 | `'on'` |
| `WindowState` | 字符串 | 窗口状态 | `'normal'`, `'minimized'`, `'maximized'` |
| `HandleVisibility` | 字符串 | 句柄可见性 | `'on'`, `'off'`, `'callback'` |
| `Visible` | `'on'`/`'off'` | 窗口是否可见 | `'on'` |
| `CloseRequestFcn` | 函数句柄 | 关闭窗口时的回调函数 | `@(src,event)closereq` |
| `SizeChangedFcn` | 函数句柄 | 窗口大小改变时的回调函数 | `@myResizeCallback` |

### 示例代码
```matlab
fig = uifigure('Name', '成绩分析系统', ...
               'Position', [100, 100, 1000, 700], ...
               'Resize', 'on', ...
               'WindowState', 'normal');
```

---

## 2. uipanel - 面板组件

### 基本语法
```matlab
panel = uipanel(parent, Name, Value, ...)
```

### 常用参数

| 参数名称 | 数据类型 | 说明 | 示例 |
|---------|---------|------|------|
| `Title` | 字符串/字符向量 | 面板标题 | `'控制面板'` |
| `Position` | 4元素数值数组 | 面板位置和大小 [x, y, width, height] | `[10, 10, 300, 200]` |
| `BorderType` | 字符串 | 边框类型 | `'none'`, `'line'`, `'etchedin'`, `'etchedout'` |
| `HighlightColor` | RGB数组 | 边框高亮颜色 | `[0.7, 0.7, 0.7]` |
| `ShadowColor` | RGB数组 | 边框阴影颜色 | `[0.5, 0.5, 0.5]` |
| `BackgroundColor` | RGB数组 | 背景颜色 | `[0.98, 0.98, 0.98]` |
| `ForegroundColor` | RGB数组 | 前景（标题）颜色 | `[0, 0, 0]` |
| `FontSize` | 数值 | 标题字体大小 | `12` |
| `FontWeight` | 字符串 | 标题字体粗细 | `'normal'`, `'bold'` |
| `TitlePosition` | 字符串 | 标题位置 | `'lefttop'`, `'centertop'`, `'righttop'` |
| `Visible` | `'on'`/`'off'` | 面板是否可见 | `'on'` |

### 边框类型说明
- `'none'`: 无边框
- `'line'`: 简单线条边框（推荐用于现代化界面）
- `'etchedin'`: 凹陷效果边框
- `'etchedout'`: 凸起效果边框

### 示例代码
```matlab
% 带圆角效果的现代化面板
panel = uipanel(parent, 'Title', '文件选择', ...
                'Position', [10, 480, 280, 180], ...
                'BorderType', 'line', ...
                'HighlightColor', [0.5, 0.8, 1.0], ...
                'BackgroundColor', [0.98, 0.99, 1.0]);
```

---

## 3. uibutton - 按钮组件

### 基本语法
```matlab
btn = uibutton(parent, Name, Value, ...)
```

### 常用参数

| 参数名称 | 数据类型 | 说明 | 示例 |
|---------|---------|------|------|
| `Text` | 字符串/字符向量 | 按钮文本 | `'开始分析'` |
| `Position` | 4元素数值数组 | 按钮位置和大小 [x, y, width, height] | `[10, 10, 100, 30]` |
| `BackgroundColor` | RGB数组 | 背景颜色 | `[0.2, 0.7, 0.2]` |
| `FontColor` | RGB数组 | 文字颜色 | `'white'` 或 `[1, 1, 1]` |
| `FontSize` | 数值 | 字体大小 | `12` |
| `FontWeight` | 字符串 | 字体粗细 | `'normal'`, `'bold'` |
| `FontName` | 字符串 | 字体名称 | `'Arial'`, `'宋体'` |
| `Enable` | `'on'`/`'off'` | 按钮是否可用 | `'on'` |
| `Visible` | `'on'`/`'off'` | 按钮是否可见 | `'on'` |
| `ButtonPushedFcn` | 函数句柄 | 按钮点击回调函数 | `@(src,event)myCallback()` |
| `Icon` | 字符串 | 图标文件路径 | `'icon.png'` |
| `IconAlignment` | 字符串 | 图标对齐方式 | `'left'`, `'right'`, `'top'`, `'bottom'` |
| `WordWrap` | `'on'`/`'off'` | 文字换行 | `'off'` |
| `HorizontalAlignment` | 字符串 | 水平对齐 | `'center'`, `'left'`, `'right'` |
| `VerticalAlignment` | 字符串 | 垂直对齐 | `'center'`, `'top'`, `'bottom'` |

### 按钮样式示例
```matlab
% 主要操作按钮（绿色）
primaryBtn = uibutton(parent, 'push', 'Text', '开始分析', ...
                     'Position', [10, 70, 260, 35], ...
                     'FontWeight', 'bold', ...
                     'BackgroundColor', [0.2, 0.7, 0.2], ...
                     'FontColor', 'white');

% 次要操作按钮（灰色）
secondaryBtn = uibutton(parent, 'push', 'Text', '重置', ...
                       'Position', [10, 25, 125, 30], ...
                       'BackgroundColor', [0.9, 0.9, 0.9], ...
                       'FontColor', [0.3, 0.3, 0.3]);

% 信息按钮（蓝色）
infoBtn = uibutton(parent, 'push', 'Text', '导出结果', ...
                  'Position', [145, 25, 125, 30], ...
                  'BackgroundColor', [0.2, 0.5, 0.8], ...
                  'FontColor', 'white');
```

---

## 4. uigridlayout - 网格布局

### 基本语法
```matlab
grid = uigridlayout(parent, [rows, columns])
```

### 常用参数

| 参数名称 | 数据类型 | 说明 | 示例 |
|---------|---------|------|------|
| `RowHeight` | 元胞数组 | 行高设置 | `{'1x', 50, '2x'}` |
| `ColumnWidth` | 元胞数组 | 列宽设置 | `{300, '1x'}` |
| `Padding` | 4元素数组 | 内边距 [left, bottom, right, top] | `[10, 10, 10, 10]` |
| `RowSpacing` | 数值 | 行间距 | `10` |
| `ColumnSpacing` | 数值 | 列间距 | `10` |
| `Scrollable` | `'on'`/`'off'` | 是否可滚动 | `'off'` |

### 子组件布局属性
```matlab
component.Layout.Row = 1;        % 行位置
component.Layout.Column = 2;     % 列位置
component.Layout.RowSpan = [1 3]; % 跨行
component.Layout.ColumnSpan = [1 2]; % 跨列
```

---

## 5. 其他常用UI组件

### 5.1 uilabel - 标签

```matlab
label = uilabel(parent, 'Text', '标签文本', ...
               'Position', [10, 10, 100, 22], ...
               'FontSize', 14, ...
               'FontWeight', 'bold', ...
               'FontColor', [0.3, 0.3, 0.3]);
```

### 5.2 uieditfield - 输入框

```matlab
editField = uieditfield(parent, 'text', ...
                       'Position', [10, 10, 200, 22], ...
                       'Value', '默认值', ...
                       'Placeholder', '请输入...', ...
                       'ValueChangedFcn', @(src,event)myCallback());
```

### 5.3 uitextarea - 文本区域

```matlab
textArea = uitextarea(parent, ...
                     'Position', [10, 10, 300, 200], ...
                     'Value', {'第一行', '第二行'}, ...
                     'Editable', 'off', ...
                     'BackgroundColor', [1, 1, 1]);
```

### 5.4 uitable - 表格

```matlab
table = uitable(parent, ...
               'Position', [10, 10, 400, 300], ...
               'Data', data, ...
               'ColumnName', {'列1', '列2', '列3'}, ...
               'RowName', 'numbered', ...
               'ColumnEditable', [false, true, false]);
```

### 5.5 uiaxes - 图表坐标轴

```matlab
ax = uiaxes(parent, ...
           'Position', [10, 10, 400, 300], ...
           'Title', '图表标题', ...
           'XLabel', 'X轴标签', ...
           'YLabel', 'Y轴标签');
```

### 5.6 uigauge - 仪表盘

```matlab
% 线性仪表盘
gauge = uigauge(parent, 'linear', ...
               'Position', [10, 10, 200, 25], ...
               'Limits', [0, 100], ...
               'Value', 50, ...
               'ScaleColors', [0.2, 0.7, 0.2]);

% 圆形仪表盘
gauge = uigauge(parent, 'circular', ...
               'Position', [10, 10, 100, 100], ...
               'Limits', [0, 100], ...
               'Value', 75);
```

### 5.7 uitabgroup - 标签页组

```matlab
tabGroup = uitabgroup(parent, ...
                     'Position', [10, 10, 400, 300]);

tab1 = uitab(tabGroup, 'Title', '标签页1');
tab2 = uitab(tabGroup, 'Title', '标签页2');
```

---

## 6. 颜色系统

### RGB颜色值（0-1范围）
```matlab
% 常用颜色
红色 = [1, 0, 0];
绿色 = [0, 1, 0];
蓝色 = [0, 0, 1];
白色 = [1, 1, 1];
黑色 = [0, 0, 0];
灰色 = [0.5, 0.5, 0.5];

% 现代化UI配色方案
主色调_蓝 = [0.2, 0.5, 0.8];
成功_绿 = [0.2, 0.7, 0.2];
警告_橙 = [1.0, 0.7, 0.3];
错误_红 = [0.8, 0.2, 0.2];
背景_浅灰 = [0.98, 0.98, 0.98];
边框_中灰 = [0.7, 0.7, 0.7];
文字_深灰 = [0.3, 0.3, 0.3];
```

### 颜色字符串
```matlab
% MATLAB预定义颜色
'red', 'green', 'blue', 'white', 'black', 'yellow', 'magenta', 'cyan'
```

---

## 7. 回调函数

### 基本语法
```matlab
% 匿名函数
component.PropertyChangedFcn = @(src, event) disp('属性改变');

% 函数句柄
component.PropertyChangedFcn = @myCallbackFunction;

% 嵌套函数
function myCallbackFunction(src, event)
    % 处理逻辑
    disp(['组件: ', src.Type, ' 触发了事件']);
end
```

### 常用回调属性
- `ButtonPushedFcn` - 按钮点击
- `ValueChangedFcn` - 值改变
- `SelectionChangedFcn` - 选择改变
- `CellEditCallback` - 单元格编辑
- `SizeChangedFcn` - 大小改变
- `CloseRequestFcn` - 关闭请求

---

## 8. 最佳实践

### 8.1 现代化界面设计
```matlab
% 使用网格布局而非绝对定位
grid = uigridlayout(fig, [3, 2]);
grid.Padding = [10, 10, 10, 10];
grid.RowSpacing = 10;
grid.ColumnSpacing = 10;

% 统一的配色方案
primaryColor = [0.2, 0.5, 0.8];
backgroundColor = [0.98, 0.98, 0.98];
borderColor = [0.7, 0.7, 0.7];

% 统一的字体设置
fontSize = 12;
fontWeight = 'normal';
```

### 8.2 响应式设计
```matlab
% 使用相对大小而非固定像素
grid.ColumnWidth = {'1x', '2x', '1x'};  % 比例分配
grid.RowHeight = {50, '1x', 40};       % 混合设置
```

### 8.3 用户体验优化
```matlab
% 添加进度指示
waitbar或uiprogressdlg

% 错误处理和用户提示
uialert(fig, '操作完成', '提示', 'Icon', 'success');
uialert(fig, '发生错误', '错误', 'Icon', 'error');

% 禁用/启用控件
component.Enable = 'off';  % 禁用
component.Enable = 'on';   % 启用
```

### 8.4 性能优化
```matlab
% 批量操作时暂停绘制
drawnow; % 强制刷新界面

% 大数据量表格使用虚拟化
table.Data = data;  % 一次性设置而非逐行添加
```

---

## 9. 常见问题解决

### 9.1 组件重叠问题
确保Position参数不冲突，使用网格布局避免手动定位。

### 9.2 字体显示问题
```matlab
% 设置支持中文的字体
component.FontName = '微软雅黑';
component.FontSize = 12;
```

### 9.3 回调函数调试
```matlab
% 在回调函数中添加调试信息
function myCallback(src, event)
    fprintf('回调函数被触发: %s\n', src.Type);
    % 业务逻辑
end
```

### 9.4 跨平台兼容性
避免使用系统特定的字体和路径，使用相对路径和通用字体。

---

## 10. 完整示例

```matlab
function modernUIExample()
    % 创建现代化UI示例
    
    % 主窗口
    fig = uifigure('Name', '现代化界面示例', ...
                   'Position', [100, 100, 800, 600], ...
                   'Resize', 'on');
    
    % 主布局
    mainGrid = uigridlayout(fig, [1, 2]);
    mainGrid.ColumnWidth = {250, '1x'};
    mainGrid.Padding = [10, 10, 10, 10];
    mainGrid.ColumnSpacing = 10;
    
    % 左侧面板
    leftPanel = uipanel(mainGrid, 'Title', '控制面板', ...
                       'BorderType', 'line', ...
                       'HighlightColor', [0.7, 0.7, 0.7], ...
                       'BackgroundColor', [0.98, 0.98, 0.98]);
    leftPanel.Layout.Row = 1;
    leftPanel.Layout.Column = 1;
    
    % 右侧面板
    rightPanel = uipanel(mainGrid, 'Title', '结果显示', ...
                        'BorderType', 'line', ...
                        'HighlightColor', [0.7, 0.7, 0.7], ...
                        'BackgroundColor', [0.98, 0.98, 0.98]);
    rightPanel.Layout.Row = 1;
    rightPanel.Layout.Column = 2;
    
    % 添加组件到左侧面板
    btn = uibutton(leftPanel, 'push', 'Text', '点击我', ...
                  'Position', [20, 20, 100, 30], ...
                  'BackgroundColor', [0.2, 0.7, 0.2], ...
                  'FontColor', 'white', ...
                  'ButtonPushedFcn', @(src,event) disp('按钮被点击'));
end
```

这份文档涵盖了MATLAB App Designer中最重要的UI组件及其参数说明，可以作为开发现代化MATLAB应用的参考手册。 