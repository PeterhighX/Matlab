function GradeAnalysisSystem()
    % 天地三清 - 成绩分析系统（函数化重构版本）
    % 主函数：执行完整的成绩分析流程
    
        clc; clear; close;
        
        % 获取文件路径
        [scoreFile, weightFile, outputDir] = setupPaths();
        
        % 加载数据
        [dataset_score, dataset_weight, m0, n0, m1, n1] = loadData(scoreFile, weightFile);
        
        % 验证权重数据
        validateWeights(dataset_weight, m0, n1);
        
        % 计算总成绩
        dataset_score = calculateTotalScores(dataset_score, dataset_weight);
        
        % 计算达成度
        [dataset_score, achievementScores] = calculateAchievementScores(dataset_score, dataset_weight);
        
        % 分配等级
        dataset_score = assignGrades(dataset_score);
        
        % 保存所有结果
        saveResults(dataset_score, achievementScores, dataset_weight, outputDir);
        
        disp('成绩分析完成！');
    end
    
    function [scoreFile, weightFile, outputDir] = setupPaths()
    % 设置文件路径
        % 获取当前脚本所在目录
        currentDir = fileparts(mfilename('fullpath'));
        
        % 设置data相对路径
        dataDir = fullfile(currentDir, 'data');
        
        
        scoreFile = fullfile(dataDir, '附件7-2023年2021级数学建模-期末考试成绩.xlsx');
        weightFile = fullfile(dataDir, '数学建模权重.xlsx');
        outputDir = fullfile(currentDir, 'output');
        
        % 创建输出目录
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
    end
    
    function [dataset_score, dataset_weight, m0, n0, m1, n1] = loadData(scoreFile, weightFile)
    % 加载成绩和权重数据
        
        % 读取成绩数据
        opts = detectImportOptions(scoreFile);
        opts.VariableNamingRule = 'preserve';
        disp(opts);
        
        opts.VariableNamesRange = "1:1";
        opts.DataRange = "A2:C79";
        opts.Sheet = 1;
        varNames = string(opts.VariableNames);
        
        dataset_score = readtable(scoreFile, opts);
        disp(dataset_score.Properties.VariableTypes);
        
        % 清除临时变量
        clear opts varNames;
        
        % 获取表格尺寸
        temp1 = readtable(weightFile);   % 权重
        temp0 = readtable(scoreFile);    % 成绩
        [m0, n0] = size(temp1);
        [m1, n1] = size(temp0);
        clear temp0 temp1;
        
        % 读取权重数据
        opts = spreadsheetImportOptions("NumVariables", n0);
        opts.VariableTypes{1} = 'char';
        opts.VariableNamingRule = 'preserve';
        for i = 2:n0
            opts.VariableTypes{i} = 'double';
        end
        dataset_weight = readtable(weightFile, opts);
        
        clear opts i;
    end
    
    function validateWeights(dataset_weight, m0, n1)
    % 验证权重数据的正确性
        
        % 判断项目数是否匹配
        if m0-1 ~= n1
            disp("源文件有误")
        end
        
        % 检查权重总和
        weightSum = sum(table2array(dataset_weight(2:end-1, 2:end-1)), 'all');
        disp(weightSum);
        
        if weightSum ~= 1 && weightSum ~= 100
            disp("源文件有误：权重总和不是1或100")
        end
        
        % 判断目标1~3的和是否等于1
        data_targetSum = 0;
        data_target = zeros(1, 3);
        
        for i = 1:3
            data_target(i) = sum(table2array(dataset_weight(i+1, 2:end-1)), 'all');
            disp(['目标 ', num2str(i), ' 权重和为: ', num2str(data_target(i))]);
        end
        data_targetSum = sum(data_target);
        
        if abs(data_targetSum - 1) > 1e-6
            disp("源文件有误：目标1~3的和不等于1")
        else
            disp("源文件无误")
        end
        
        clear weightSum i data_targetSum data_target;
    end
    
    function dataset_score = calculateTotalScores(dataset_score, dataset_weight)
    % 计算学生总成绩
        
        % 获取权重表的项目名称
        weightRows = dataset_weight(2:end, 1);
        projectNames = table2array(weightRows);
        
        % 定义有效项目名称
        validProjects = {'考勤', '平时作业', '期末考试'};
        
        % 检查项目名称
        for i = 1:length(validProjects)
            if ~strcmp(projectNames(i), validProjects{i})
                error('权重表格中第 %d 行的项目名称不是 "%s"，请检查数据。', i, validProjects{i});
            end
        end
        
        % 验证有效项目数
        validProjectCount = sum(ismember(projectNames, validProjects));
        if validProjectCount ~= length(validProjects)
            error('权重表格中有效项目数不足，请检查是否包含 ''考勤'', ''平时作业'', ''期末考试''。');
        end
        
        % 提取权重值
        weights = table2array(dataset_weight(2:4, end));
        
        % 获取成绩表的列名
        scoreHeaders = dataset_score.Properties.VariableNames;
        [~, scoreColIndices] = ismember(validProjects, scoreHeaders);
        
        % 初始化总成绩数组
        totalScores = zeros(height(dataset_score), 1);
        
        % 计算每个学生的总成绩
        for i = 1:height(dataset_score)
            projectScores = table2array(dataset_score(i, scoreColIndices));
            weightedScore = projectScores * weights;
            totalScores(i) = weightedScore;
        end
        
        % 添加总成绩列
        dataset_score.TotalScore = totalScores;
        
        % 按总成绩降序排序
        dataset_score = sortrows(dataset_score, 'TotalScore', 'descend');
        
        fprintf('Totalscore:\n');
        disp(dataset_score);
        
        clear weights projectNames;
    end
    
    function [dataset_score, achievementScores] = calculateAchievementScores(dataset_score, dataset_weight)
    % 计算目标达成度
        
        % 获取权重表的项目名称
        weightRows = dataset_weight(2:end, 1);
        projectNames = table2array(weightRows);
        
        % 定义有效项目名称
        validProjects = {'考勤', '平时作业', '期末考试'};
        
        % 检查项目名称
        for i = 1:length(validProjects)
            if ~strcmp(projectNames(i), validProjects{i})
                error('权重表格中第 %d 行的项目名称不是 "%s"，请检查数据。', i + 1, validProjects{i});
            end
        end
        
        % 提取目标1~3的权重
        targetWeights = table2array(dataset_weight(2:4, 2:4));
        
        % 获取成绩表的列名
        scoreHeaders = dataset_score.Properties.VariableNames;
        [~, scoreColIndices] = ismember(validProjects, scoreHeaders);
        
        % 初始化达成度数组
        achievementScores = zeros(height(dataset_score), 3);
        
        % 计算每个学生的达成度
        for i = 1:height(dataset_score)
            projectScores = table2array(dataset_score(i, scoreColIndices));
            for j = 1:3
                achievementScores(i, j) = projectScores * targetWeights(:, j);
            end
        end
        
        % 添加达成度列
        dataset_score.Achievement_Target1 = achievementScores(:, 1);
        dataset_score.Achievement_Target2 = achievementScores(:, 2);
        dataset_score.Achievement_Target3 = achievementScores(:, 3);
        
        % 重新排序
        dataset_score = sortrows(dataset_score, 'TotalScore', 'descend');
    end
    
    function dataset_score = assignGrades(dataset_score)
    % 根据总成绩分配等级
        
        % 初始化 Grade 列
        dataset_score.Grade = strings(height(dataset_score), 1);
        
        % 分档逻辑
        for i = 1:height(dataset_score)
            score = dataset_score.TotalScore(i);
            if score >= 90
                dataset_score.Grade(i) = "A";
            elseif score >= 80
                dataset_score.Grade(i) = "B";
            elseif score >= 70
                dataset_score.Grade(i) = "C";
            elseif score >= 60
                dataset_score.Grade(i) = "D";
            else
                dataset_score.Grade(i) = "E";
            end
        end
        
        % 显示等级分布
        disp("学生等级分布：");
        disp(dataset_score(:, {'TotalScore', 'Grade'}));
    end
    
    function saveResults(dataset_score, achievementScores, dataset_weight, outputDir)
    % 保存所有分析结果
        
        % 1. 保存学生成绩排名
        outputFile1 = fullfile(outputDir, '学生成绩排名.xlsx');
        writetable(dataset_score, outputFile1);
        disp(['已将结果保存至：', outputFile1]);
        
        % 2. 保存学生成绩达成度分析
        outputFile2 = fullfile(outputDir, '学生成绩达成度分析.xlsx');
        writetable(dataset_score, outputFile2);
        disp(['已将达成度分析结果保存至：', outputFile2]);
        
        % 3. 计算并保存目标达成度统计
        targetNames = {'目标1', '目标2', '目标3'};
        targetWeights = table2array(dataset_weight(end, 2:4)) * 100;
        averageAchievement = mean(achievementScores, 1);
        
        summaryTable = table('Size', [length(targetNames), 4], ...
            'VariableTypes', {'double', 'double', 'double', 'double'}, ...
            'VariableNames', {'target', 'val', 'ave_score', 'ave_per'});
        
        for i = 1:length(targetNames)
            summaryTable.target(i) = i;
            summaryTable.val(i) = targetWeights(i);
            summaryTable.ave_score(i) = averageAchievement(i);
            summaryTable.ave_per(i) = averageAchievement(i) / summaryTable.val(i) * 100;
        end
        
        disp(summaryTable);
        
        outputFile3 = fullfile(outputDir, '目标达成度分析.xlsx');
        writetable(summaryTable, outputFile3);
        disp(['已将目标达成度统计结果保存至：', outputFile3]);
        
        % 4. 保存成绩等级分布
        grades = ["A", "B", "C", "D", "E"];
        gradeCounts = zeros(size(grades));
        for i = 1:length(grades)
            gradeCounts(i) = sum(strcmp(dataset_score.Grade, grades(i)));
        end
        
        gradeSummaryTable = table(grades', gradeCounts', ...
            'VariableNames', {'Grade', 'Count'});
        
        outputFile4 = fullfile(outputDir, '成绩等级分布.xlsx');
        writetable(dataset_score(:, {'TotalScore', 'Grade'}), outputFile4, 'Sheet', '成绩等级明细');
        writetable(gradeSummaryTable, outputFile4, 'Sheet', '等级人数统计', 'WriteMode', 'append');
        disp(['已将成绩等级分布保存至：', outputFile4]);
    end