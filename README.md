# 成绩分析系统 - 使用说明

## 项目概述

本项目是一个基于MATLAB的成绩分析系统，专门用于教学评价和课程目标达成度分析。系统提供图形界面和命令行两种使用方式，能够自动处理学生成绩数据、计算目标达成度、生成统计报表和Word分析报告。

## 主要功能

### 🎯 核心功能
- **成绩数据分析**：自动读取Excel格式的成绩数据进行统计分析
- **权重配置管理**：支持灵活的权重设置和实时编辑
- **目标达成度评价**：基于权重计算各课程目标的达成情况
- **等级分布统计**：生成详细的成绩等级分布报告
- **多样化报表生成**：支持生成Excel表格和Word分析报告

### 📊 分析报表
- 学生成绩排名表
- 成绩等级分布统计
- 目标达成度分析报告
- 横向树状评价表
- 目标达成度等级统计表
- 完整的Word格式分析报告

## 系统要求

### 软件要求
- **MATLAB** R2019b 或更高版本
- **Microsoft Excel** 2016 或更高版本
- **Microsoft Word** 2016 或更高版本（用于生成Word报告）

### 工具箱依赖
- Statistics and Machine Learning Toolbox（统计分析）
- Spreadsheet Link（Excel读写）

## 安装和设置

1. **克隆或下载项目**
   ```bash
   git clone [项目地址]
   cd Matlab
   ```

2. **准备数据文件**
   - 将成绩数据文件放入 `data/` 目录
   - 确保权重配置文件格式正确
   - 检查Word报告模板是否存在

3. **MATLAB环境设置**
   - 将项目文件夹添加到MATLAB路径
   - 确保具有文件读写权限

## 使用方法

### 方式一：图形界面（推荐）

1. **启动应用程序**
   ```matlab
   GradeAnalysisApp
   ```

2. **配置文件路径**
   - 成绩文件：选择包含学生成绩的Excel文件
   - 权重文件：选择权重配置Excel文件
   - 输出目录：设置结果保存路径

3. **权重设置**
   - 选择"从文件读取"或"手动编辑"模式
   - 在表格中直接修改权重值
   - 点击"保存"按钮保存修改

4. **执行分析**
   - 点击"开始分析"按钮
   - 系统将显示分析进度
   - 分析完成后可导出结果

5. **生成报告**
   - 点击"生成Word报告"创建详细报告
   - 报告将自动保存到输出目录

### 方式二：命令行运行

1. **快速分析**
   ```matlab
   runAnalysis
   ```
   此命令将使用默认路径执行完整分析流程

2. **自定义分析**
   ```matlab
   % 创建分析对象
   analyzer = GradeAnalysisClass('成绩文件路径', '权重文件路径', '输出目录');
   
   % 设置进度监控
   analyzer.setProgressCallback(@(msg, pct) fprintf('[%3.0f%%] %s\n', pct, msg));
   
   % 执行分析
   success = analyzer.runCompleteAnalysis();
   
   % 获取结果
   results = analyzer.getResults();
   ```

3. **生成单独报表**
   ```matlab
   % 生成横向树状表
   generateHorizontalTreeTable();
   
   % 生成等级统计表
   generateAchievementLevelTable();
   
   % 生成Word报告
   SimpleWordReportGenerator(true); % true表示自动打开文件
   ```

## 文件结构

```
Matlab/
├── README.md                              # 使用说明文档
├── GradeAnalysisApp.m                     # 图形界面主程序
├── GradeAnalysisClass.m                   # 核心分析类
├── runAnalysis.m                          # 命令行测试脚本
├── SimpleWordReportGenerator.m            # Word报告生成器
├── generateAchievementLevelTable.m        # 等级统计表生成器
├── generateHorizontalTreeTable.m          # 横向树状表生成器
├── data/                                  # 数据文件目录
│   ├── 数学建模权重.xlsx                  # 权重配置文件
│   ├── 附件7-2023年2021级数学建模-期末考试成绩.xlsx  # 成绩数据
│   └── 附件4.课程目标达成情况分析报告模板.dotx      # Word报告模板
├── output/                                # 分析结果输出目录
├── refer_word/                            # 参考文档目录
│   ├── 大作业说明.docx                    # 项目说明文档
│   ├── MATLAB_UI组件参数说明.md           # UI组件说明
│   └── 附件*.docx                         # 各类参考文档
└── refer_excel/                           # 参考Excel模板
    └── 权重.xlsx                          # 权重配置参考
```

## 数据格式要求

### 成绩数据文件格式
- **文件类型**：Excel (.xlsx)
- **数据结构**：
  - 第一行：表头（学号、姓名、各项成绩等）
  - 后续行：学生数据
  - 成绩列：数值格式，支持空值

### 权重配置文件格式
- **文件类型**：Excel (.xlsx)
- **数据结构**：
  - 第一行：目标表头
  - 第2-4行：各评价方式及其权重
  - 最后一行：权重合计（用于验证）

## 输出结果说明

### Excel报表文件
- `学生成绩排名.xlsx` - 按总分排序的学生成绩表
- `成绩等级分布.xlsx` - 各等级学生人数和比例统计
- `目标达成度分析.xlsx` - 各目标达成度详细分析
- `目标评价横向树状表.xlsx` - 目标评价体系树状结构表
- `目标达成度等级统计表.xlsx` - 各等级达成度统计表

### Word分析报告
- 包含完整的分析过程和结果
- 自动插入Excel表格数据
- 基于预设模板生成标准格式报告

## 使用示例

### 示例1：标准分析流程
```matlab
% 启动图形界面
GradeAnalysisApp

% 1. 选择成绩文件：data/附件7-2023年2021级数学建模-期末考试成绩.xlsx
% 2. 选择权重文件：data/数学建模权重.xlsx
% 3. 设置输出目录：output/
% 4. 点击"开始分析"
% 5. 点击"生成Word报告"
```

### 示例2：命令行批处理
```matlab
% 执行完整分析
runAnalysis;

% 生成额外报表
generateHorizontalTreeTable();
generateAchievementLevelTable();

% 生成Word报告并自动打开
SimpleWordReportGenerator(true);
```

### 示例3：自定义权重分析
```matlab
% 创建分析器实例
analyzer = GradeAnalysisClass();

% 加载数据
analyzer.loadData();

% 获取并修改权重数据
weights = analyzer.getWeightData();
% 修改权重值...

% 重新运行分析
analyzer.runCompleteAnalysis();

% 获取结果
results = analyzer.getResults();
```

## 常见问题解决

### Q1: 程序无法读取Excel文件
**解决方案**：
- 检查文件路径是否正确
- 确保Excel文件未被其他程序打开
- 验证文件格式是否为.xlsx

### Q2: 权重设置无效
**解决方案**：
- 检查权重文件格式是否正确
- 确保权重值为数值格式
- 验证权重总和是否为1

### Q3: Word报告生成失败
**解决方案**：
- 确保安装了Microsoft Word
- 检查Word模板文件是否存在
- 验证输出目录的写入权限

### Q4: 分析结果异常
**解决方案**：
- 检查成绩数据是否包含非法字符
- 验证学生人数与成绩数据行数是否一致
- 查看命令行窗口的错误信息

## 技术支持

### 版本信息
- 当前版本：v1.4 (input_improve)
- 最后更新：2024年

### 联系方式
如遇技术问题，请参考以下资源：
- 查看 `refer_word/` 目录中的详细文档
- 检查MATLAB命令行窗口的错误信息
- 确保所有依赖项已正确安装

### 更新日志
- v1.4: 改进了输入验证和用户界面
- v1.3: 增加了Word报告自动生成功能
- v1.2: 优化了权重配置管理
- v1.1: 添加了图形界面支持
- v1.0: 初始版本发布

---

**注意**：本系统专为教学评价设计，请确保输入数据的准确性和完整性，以获得可靠的分析结果。 