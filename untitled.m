%% 导入电子表格中的数据
% 用于从以下电子表格导入数据的脚本:
%
%    工作簿: D:\code\code02\matlab\bigwork\附件7-2023年2021级数学建模-期末考试成绩.xlsx
%    工作表: Sheet1
%
% 由 MATLAB 于 2025-05-09 16:38:21 自动生成

%% 设置导入选项并导入数据
opts = spreadsheetImportOptions("NumVariables", 10);

% 指定工作表和范围
opts.Sheet = "Sheet1";
opts.DataRange = "A2:J79";

% 指定列名称和类型
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% 指定变量属性
opts = setvaropts(opts, ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10"], "EmptyFieldRule", "auto");

% 导入数据
Untitled = readtable("D:\code\code02\matlab\bigwork\附件7-2023年2021级数学建模-期末考试成绩.xlsx", opts, "UseExcel", false);


%% 清除临时变量
clear opts