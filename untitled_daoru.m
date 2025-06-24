%%%% 期末试卷达成度分析
%%%% 作者：周建熹
%%%% 修改日期：2025.5.9

%%%%%%%%%%%%导入部分代码实现思路%%%%%%%%%%%%%%
% 1.将成绩、权重的两个Excel文件导入matlab；
%   A.搜索得到readtable函数可实现读取功能
%   B.直接使用readtable，不能满足要求
%   C.发现，自带工具，手动导入，可以满足要求，但不够好
%   D.又发现，自带工具可生成等效的代码，与手动点击效果相同
%   E.因此，学习等效代码，在此基础上进行修改，实现更好的适配
% 2.检查导入文件是否符合要求
% 分析 成绩.xlsx(行——学生，列——项目)
%      权重.xlsx(行——项目，列——目标)
% A.判断项目数相等
% B.判断权重加起来是否等于1或者100
%    B1.如果总权重等于100，将总权重转化为1
% C.判断表头顺序
%    C1.如果顺序不正确，则以权重中项目的顺序为准，重新生成成绩表格
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 清除变量，关闭窗口

close all;clear all;clc;
%% 需读取的文件名

filename_quanzhong='D:\杂项\数学建模权重.xlsx';
filename_chengji="D:\杂项\附件7-2023年2021级数学建模-期末考试成绩.xlsx";
%% 判断并确定表格行列数

temp0=readtable(filename_quanzhong);%权重
%获得权重表格的行数m0(理论上=项目数+2)、列数n0(目标数+2)，注意默认读取时，权重table丢失第一行
[m0 n0]=size(temp0);
%获得成绩表格的行数m1(理论上=学生人数+1)、列数n1(项目数)，注意默认读取时，成绩table丢失第一行
temp1=readtable(filename_chengji);
[m1 n1]=size(temp1);
if m0-1 ~= n1 %权重.xlsx第一行为表头,最后一行是合计，项目数应该为行数-2
    %但默认读取时权重table丢失第一行，因此项目数为行数m0-1
    disp("源文件有误")
end
clear temp0 temp1
%% 导入 权重.xlsx

opts=spreadsheetImportOptions("NumVariables", n0);
opts.VariableTypes{1}='char';
for i=2:n0
    opts.VariableTypes{i}='double';
end
quanzhong_table=readtable(filename_quanzhong, opts);
%% 清除临时变量

clear opts n VariableNames VariableTypes i temp
%% 导入学生成绩

opts=spreadsheetImportOptions("NumVariables", n1);
chengji_table= readtable(filename_chengji, opts);
%% 清除临时变量

clear opts
%% 判断输入权重
temp = table2array(sum(quanzhong_table(2:end-1,2:end-1),'all'));
if temp == 100
    quanzhong_table(2:end,2:end)=quanzhong_table(2:end,2:end)./100;
elseif temp~=1
    error('权重总和不等于1或100')
end
sum(quanzhong_table(2:end-1,2:end-1),1)
sum(quanzhong_table(2:end-1,2:end-1),2)

% weight_subset = weight_table(2:4,5);
% weight_sum = sum(weight_subset);
% if ~(weight_sum == 1 || weight_sum ==100)
    % error('权重总和不等于1或100')
% end

% if weight_sum == 100
    % weight_table{2:4,5} = weight_table{2:4,5}/100;
% end
%% 判断源文件表头顺序

table2array(chengji_table(1,i))
table2array(quanzhong_table(i+1,1))
% for i=1:n1
%     if chengji_table(1,i) == quanzhong_table(i+1,1)  % 将table转换为同构数组
%         disp('匹配')
%     else
%         disp('不匹配')
%     end
% end

%% 
% Z=table2array(quanzhong_table(2:end-1,2:end-1)); sum(Z,"all");
% 
%