% 天地三清
clc;clear;close;

%% 设置file路径，存入变量
% 获取当前脚本所在目录
currentDir = fileparts(mfilename('fullpath'));

% 设置data相对路径，防止调用的时文件路径不一致出错
dataDir = fullfile(currentDir, 'data');

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

% 使用配置读取表格
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


% table2array(dataset_score(1,i))
% table2array(dataset_weight(i+1,1))





