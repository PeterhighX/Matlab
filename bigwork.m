% 天地三清
clc;clear;close;

%% 设置file路径，存入变量
% 获取当前脚本所在目录
currentDir = fileparts(mfilename('fullpath'));

% 设置data相对路径，防止调用的时文件路径不一致出错
dataDir = fullfile(currentDir, 'data');

% 打开 Workspace 窗口并显示当前工作区变量
openvar('dataset_score');

file1 = fullfile(dataDir, '附件7-2023年2021级数学建模-期末考试成绩.xlsx');
file2 = fullfile(dataDir, '数学建模权重.xlsx');

%% 创建导入选项对象
opts = detectImportOptions(file1);
opts.VariableNamingRule = 'preserve'; % 保留变量名

% 查看当前配置
disp(opts);

% 修改配置
opts.VariableNamesRange = "1:1";             % 设置第1行为表头
opts.DataRange = "A2:C79";              % 数据从第2行开始
opts.Sheet = 1;                         % 选择第一个工作表
varNames = string(opts.VariableNames);          % 获取变量名

% 使用配置读取 成绩 表格
dataset_score = readtable(file1, opts);
disp(dataset_score.Properties.VariableTypes);

% 清除临时变量opts
clear opts varNames ;

%% 判断并确定表格行列数

temp1=readtable(file2);   %权重
temp0=readtable(file1);   %成绩
% 获得权重表格的行数m0(理论上=项目数+2)、列数n0(目标数+2)，注意默认读取时，权重table丢失第一行
[m0 n0]=size(temp1);
% 获取成绩表格的行列数m1，n1，借此判断两个表格的项目数是否匹配
[m1 n1]=size(temp0);
clear temp0 temp1;

%% 导入 权重.xlsx
opts=spreadsheetImportOptions("NumVariables", n0);
opts.VariableTypes{1}='char';
opts.VariableNamingRule = 'preserve'; % 保留变量名
for i=2:n0
    opts.VariableTypes{i}='double';
end
dataset_weight=readtable(file2, opts);

%%% 清除临时变量
clear opts n VariableNames VariableTypes i temp;

%% 判断权重是否有误
if m0-1 ~= n1 %权重.xlsx第一行为表头,最后一行是合计，项目数应该为行数-2
              %但默认读取时权重table丢失第一行，因此项目数为行数m0-1
     disp("源文件有误")
end

weightSum = sum(table2array(dataset_weight(2:end-1, 2:end-1)), 'all');
disp(weightSum);

if weightSum ~= 1 && weightSum ~= 100

    disp("源文件有误：权重总和不是1或100")
end

% 判断目标1~3的和是否等于1
data_targetSum = 0;
data_target = zeros(1, 3);

for i = 1:3
    data_target(i) = sum(table2array(dataset_weight(i+1, 2:end-1)),'all');
        disp(['目标 ', num2str(i), ' 权重和为: ', num2str(data_target(i))]);
end
data_targetSum = sum(data_target);

if abs(data_targetSum -1) > 1e-6;
    disp("源文件有误：目标1~3的和不等于1")
else
    disp("源文件无误")
end
% 清除临时变量
clear weightSum i data_targetSum data_target;

%% 计算实际成绩
% 获取 dataset_weight 的行名称（即项目名称）
weightRows = dataset_weight(2:end, 1); % 第一列为项目名称
projectNames = table2array(weightRows); % 转换为 cell 数组

% 定义有效项目名称
validProjects = {'考勤', '平时作业', '期末考试'};

% 检查前三行是否分别为 '考勤'、'平时作业'、'期末考试', 忽略第一行为目标名称
for i = 1:length(validProjects)
    if ~strcmp(projectNames(i), validProjects{i})
        error('权重表格中第 %d 行的项目名称不是 "%s"，请检查数据。', i, validProjects{i});
    end
end

% 动态识别有效项目行数
validProjectCount = sum(ismember(projectNames, validProjects)); % 实际匹配的项目数
if validProjectCount ~= length(validProjects)
    error('权重表格中有效项目数不足，请检查是否包含 ''考勤'', ''平时作业'', ''期末考试''。');
end

% 提取第二行~第四行的最后一列作为权重值
weights = table2array(dataset_weight(2:4, end)); % 最后一列为对应的权重

% 获取成绩表的列名
scoreHeaders = dataset_score.Properties.VariableNames;
% 找出与有效项目匹配的列索引
[~, scoreColIndices] = ismember(validProjects, scoreHeaders);

% 初始化总成绩数组
totalScores = zeros(height(dataset_score), 1);

% 根据动态列索引提取成绩并计算总成绩
for i = 1:height(dataset_score)
    % 提取当前学生对应项目的成绩（使用动态列索引）
    projectScores = table2array(dataset_score(i, scoreColIndices));
    
    % 计算加权总成绩
    weightedScore = projectScores * weights; % 使用三个项目的权重
    
    totalScores(i) = weightedScore; % 存储总成绩
end


% 添加总成绩列到表格
dataset_score.TotalScore = totalScores;

% 对更新后的表格按总成绩降序排序
sortedDataset = sortrows(dataset_score, 'TotalScore', 'descend');

% 显示结果
fprintf('Totalscore:\n');
disp(sortedDataset);

% 清除临时变量
clear weights projectNames;

%% 将结果写入 Excel 文件

% 构造输出路径
outputDir = fullfile(currentDir, 'output'); % 使用与主程序同级的 output 文件夹
if ~exist(outputDir, 'dir')
    mkdir(outputDir); % 如果 output 文件夹不存在，则创建
end

% 构造输出文件路径
outputFile = fullfile(outputDir, '学生成绩排名.xlsx');

% 写入 Excel 文件
writetable(sortedDataset, outputFile);

% 显示保存信息
disp(['已将结果保存至：', outputFile]);

% ... existing code ...

%% 提取目标1~3的权重并计算达成度

% 获取 dataset_weight 的有效项目名（从第二行开始）
weightRows = dataset_weight(2:end, 1); % 舍弃第一行标题
projectNames = table2array(weightRows);

% 定义有效项目名称
validProjects = {'考勤', '平时作业', '期末考试'};

% 检查前三行是否分别为 '考勤'、'平时作业'、'期末考试'
for i = 1:length(validProjects)
    if ~strcmp(projectNames(i), validProjects{i})
        error('权重表格中第 %d 行的项目名称不是 "%s"，请检查数据。', i + 1, validProjects{i});
    end
end

% 提取目标1~3的权重（第2~4行 × 第2~4列）
targetWeights = table2array(dataset_weight(2:4, 2:4)); % 去掉第一列项目名和最后一列合计

% 获取成绩表的列名
scoreHeaders = dataset_score.Properties.VariableNames;

% 找出与有效项目匹配的列索引
[~, scoreColIndices] = ismember(validProjects, scoreHeaders);

% 初始化达成度数组
achievementScores = zeros(height(dataset_score), 3);

% 遍历每位学生
for i = 1:height(dataset_score)
    % 提取当前学生对应项目的成绩
    projectScores = table2array(dataset_score(i, scoreColIndices));
    % 分别计算目标1~3的达成度
    for j = 1:3
        achievementScores(i, j) = projectScores * targetWeights(:, j);
    end
end

% 添加达成度列到原表格
dataset_score.Achievement_Target1 = achievementScores(:, 1);
dataset_score.Achievement_Target2 = achievementScores(:, 2);
dataset_score.Achievement_Target3 = achievementScores(:, 3);

% 排序（按总成绩降序）
sortedDataset = sortrows(dataset_score, 'TotalScore', 'descend');

% 构造输出路径
outputDir = fullfile(currentDir, 'output');
if ~exist(outputDir, 'dir')
    mkdir(outputDir); % 如果 output 文件夹不存在，则创建
end

% 输出文件路径
outputFile = fullfile(outputDir, '学生成绩达成度分析.xlsx');

% 写入 Excel 文件
writetable(sortedDataset, outputFile);

% 显示保存信息
disp(['已将达成度分析结果保存至：', outputFile]);


%% 计算目标1~3的平均达成度及达成率

% 定义目标名称和对应的占比值（从权重表提取）
targetNames = {'目标1', '目标2', '目标3'};
targetWeights = table2array(dataset_weight(end, 2:4)) * 100; % 合计行第2~4列为占比
averageAchievement = mean(achievementScores, 1); % 求平均达成度分数

% 创建空表格，预设字段和大小
summaryTable = table('Size', [length(targetNames), 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'target', 'val', 'ave_score', 'ave_per'});

% 填充每项目标的数据
for i = 1:length(targetNames)
    summaryTable.target(i) = i; % 目标编号
    summaryTable.val(i) = targetWeights(i); % 占比值
    summaryTable.ave_score(i) = averageAchievement(i); % 平均分数
    summaryTable.ave_per(i) = averageAchievement(i) / summaryTable.val(i) * 100; % 达成率
end

% 显示结果
disp(summaryTable);

% 输出路径配置
outputDir = fullfile(currentDir, 'output');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% 输出文件路径
outputSummaryFile = fullfile(outputDir, '目标达成度统计分析.xlsx');

% 写入 Excel 文件
writetable(summaryTable, outputSummaryFile);

% 提示保存路径
disp(['已将目标达成度统计结果保存至：', outputSummaryFile]);

%% 根据学生最终总成绩，分为ABCDEF五档

% 初始化 Grade 列
sortedDataset.Grade = strings(height(sortedDataset), 1);

% 分档逻辑
for i = 1:height(sortedDataset)
    score = sortedDataset.TotalScore(i);
    if score >= 90
        sortedDataset.Grade(i) = "A";
    elseif score >= 80
        sortedDataset.Grade(i) = "B";
    elseif score >= 70
        sortedDataset.Grade(i) = "C";
    elseif score >= 60
        sortedDataset.Grade(i) = "D";
    else
        sortedDataset.Grade(i) = "E";
    end
end

% 显示带等级的成绩表（去掉 '姓名'）
disp("学生等级分布：");
disp(sortedDataset(:, {'TotalScore', 'Grade'}));

% 统计各等级人数
grades = ["A", "B", "C", "D", "E"];
gradeCounts = zeros(size(grades));
for i = 1:length(grades)
    gradeCounts(i) = sum(strcmp(sortedDataset.Grade, grades(i)));
end

% 创建统计表格
gradeSummaryTable = table(grades', gradeCounts', ...
    'VariableNames', {'Grade', 'Count'});

% 构造输出路径
outputDir = fullfile(currentDir, 'output');

% 输出文件路径
outputFile = fullfile(outputDir, '学生成绩等级分布.xlsx');

% 写入 Excel 文件（去掉 '姓名'）
writetable(sortedDataset(:, {'TotalScore', 'Grade'}), outputFile, 'Sheet', '成绩等级明细');
writetable(gradeSummaryTable, outputFile, 'Sheet', '等级人数统计', 'WriteMode', 'append');

% 提示保存路径
disp(['已将成绩等级分布保存至：', outputFile]);