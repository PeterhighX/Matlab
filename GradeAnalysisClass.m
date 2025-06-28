classdef GradeAnalysisClass < handle
    % 天地三清 - 成绩分析系统（类封装版本）
    % 面向对象的成绩分析系统，支持App调用和进度监控
    
    properties (Access = private)
        % 文件路径
        ScoreFile char
        WeightFile char
        OutputDir char
        
        % 数据存储
        DatasetScore table
        DatasetWeight table
        AchievementScores double
        
        % 数据维度信息
        M0 double  % 权重表行数
        N0 double  % 权重表列数
        M1 double  % 成绩表行数
        N1 double  % 成绩表列数
        
        % 状态标志
        IsDataLoaded logical = false
        IsAnalysisComplete logical = false
    end
    
    properties (Access = public)
        % 进度回调函数
        ProgressCallback function_handle
        
        % 分析结果状态
        AnalysisResults struct
    end
    
    methods (Access = public)
        function obj = GradeAnalysisClass(scoreFile, weightFile, outputDir)
            % 构造函数
            % 输入参数:
            %   scoreFile - 成绩文件路径（可选）
            %   weightFile - 权重文件路径（可选）
            %   outputDir - 输出目录路径（可选）
            
            if nargin == 0
                % 使用默认路径
                obj.setupDefaultPaths();
            else
                % 使用指定路径
                obj.ScoreFile = scoreFile;
                obj.WeightFile = weightFile;
                obj.OutputDir = outputDir;
            end
            
            % 创建输出目录
            if ~exist(obj.OutputDir, 'dir')
                mkdir(obj.OutputDir);
            end
            
            % 初始化结果结构
            obj.initializeResults();
        end
        
        function success = runCompleteAnalysis(obj)
            % 运行完整的分析流程
            % 返回: success - 是否成功完成分析
            
            try
                obj.updateProgress('开始成绩分析...', 0);
                
                % 步骤1: 加载数据
                obj.loadData();
                obj.updateProgress('数据加载完成', 15);
                
                % 步骤2: 验证权重数据
                obj.validateWeights();
                obj.updateProgress('权重验证完成', 30);
                
                % 步骤3: 计算总成绩
                obj.calculateTotalScores();
                obj.updateProgress('总成绩计算完成', 50);
                
                % 步骤4: 计算达成度
                obj.calculateAchievementScores();
                obj.updateProgress('达成度计算完成', 70);
                
                % 步骤5: 分配等级
                obj.assignGrades();
                obj.updateProgress('等级分配完成', 85);
                
                % 步骤6: 保存结果
                obj.saveResults();
                obj.updateProgress('结果保存完成', 95);
                
                % 步骤7: 生成分析报告
                obj.generateAnalysisReport();
                obj.updateProgress('分析完成！', 100);
                
                obj.IsAnalysisComplete = true;
                success = true;
                
            catch ME
                obj.updateProgress(['错误: ' ME.message], -1);
                success = false;
                rethrow(ME);
            end
        end
        
        function results = getResults(obj)
            % 获取分析结果
            if ~obj.IsAnalysisComplete
                error('分析尚未完成，请先运行 runCompleteAnalysis()');
            end
            results = obj.AnalysisResults;
        end
        
        function scores = getScoreData(obj)
            % 获取成绩数据
            if ~obj.IsDataLoaded
                error('数据尚未加载，请先运行 loadData() 或 runCompleteAnalysis()');
            end
            scores = obj.DatasetScore;
        end
        
        function weights = getWeightData(obj)
            % 获取权重数据
            if ~obj.IsDataLoaded
                error('数据尚未加载，请先运行 loadData() 或 runCompleteAnalysis()');
            end
            weights = obj.DatasetWeight;
        end
        
        function summary = getGradeSummary(obj)
            % 获取等级分布摘要
            if ~obj.IsAnalysisComplete
                error('分析尚未完成，请先运行 runCompleteAnalysis()');
            end
            summary = obj.AnalysisResults.GradeSummary;
        end
        
        function setProgressCallback(obj, callback)
            % 设置进度回调函数
            % 回调函数格式: function callback(message, percentage)
            obj.ProgressCallback = callback;
        end
        
        function outputDir = getOutputDir(obj)
            % 获取输出目录路径
            outputDir = obj.OutputDir;
        end
        
        function generateHorizontalTreeTable(obj)
            % 生成横向树状表格
            % 表格包含：目标 | 评价方式 | 权重 | 总分值 | 平均得分 | 达成情况
            
            if ~obj.IsAnalysisComplete
                error('分析尚未完成，请先运行 runCompleteAnalysis()');
            end
            
            try
                % 获取权重数据和目标表头
                weightData = obj.DatasetWeight;
                
                % 直接设置目标名称为目标1~3
                targetHeaders = {'目标1', '目标2', '目标3'};
                
                % 获取评价方式名称（第2-4行，第1列）
                evaluationMethods = table2array(weightData(2:4, 1));
                
                % 获取权重值（第2-4行，第2-4列）
                weightValues = table2array(weightData(2:4, 2:4));
                
                % 获取目标达成度数据
                targetFile = fullfile(obj.OutputDir, '目标达成度分析.xlsx');
                targetSummary = readtable(targetFile);
                avePerValues = targetSummary.ave_per; % 达成情况百分比
                
                % 计算每个评价方式的平均得分
                % 基于Achievement_Target1~3的平均值和权重占比
                avgTargetScores = mean(obj.AchievementScores, 1); % 每个目标的平均达成分数
                
                % 创建结果表格
                numRows = 0;
                for i = 1:3
                    numRows = numRows + length(evaluationMethods);
                end
                
                % 初始化结果数组
                resultData = cell(numRows, 6);
                rowIdx = 1;
                
                % 填充数据
                for target = 1:3
                    targetName = targetHeaders{target};
                    
                    for method = 1:length(evaluationMethods)
                        % 目标名称（仅在每个目标的第一行显示）
                        if method == 1
                            resultData{rowIdx, 1} = targetName;
                        else
                            resultData{rowIdx, 1} = '';
                        end
                        
                        % 评价方式
                        resultData{rowIdx, 2} = evaluationMethods{method};
                        
                        % 权重（百分比）
                        weight = weightValues(method, target);
                        resultData{rowIdx, 3} = sprintf('%.1f%%', weight * 100);
                        
                        % 总分值（100分 * 权重）
                        totalScore = 100 * weight;
                        resultData{rowIdx, 4} = sprintf('%.1f', totalScore);
                        
                        % 平均得分（目标平均分 * 该评价方式在该目标中的权重占比）
                        % 计算该评价方式在当前目标中的权重占比
                        targetTotalWeight = sum(weightValues(:, target));
                        methodRatio = weight / targetTotalWeight;
                        avgScore = avgTargetScores(target) * methodRatio;
                        resultData{rowIdx, 5} = sprintf('%.2f', avgScore);
                        
                        % 达成情况（仅在每个目标的第一行显示）
                        if method == 1
                            resultData{rowIdx, 6} = sprintf('%.2f%%', avePerValues(target));
                        else
                            resultData{rowIdx, 6} = '';
                        end
                        
                        rowIdx = rowIdx + 1;
                    end
                end
                
                % 创建表格
                columnNames = {'目标', '评价方式', '权重', '总分值', '平均得分', '达成情况'};
                resultTable = cell2table(resultData, 'VariableNames', columnNames);
                
                % 保存到Excel文件
                outputFile = fullfile(obj.OutputDir, '目标评价横向树状表.xlsx');
                writetable(resultTable, outputFile);
                
                % 更新进度
                obj.updateProgress('横向树状表格生成完成', 100);
                fprintf('横向树状表格已保存至：%s\n', outputFile);
                
            catch ME
                obj.updateProgress(['生成横向树状表格时出错: ' ME.message], -1);
                rethrow(ME);
            end
        end
        
        function generateAchievementLevelTable(obj)
            % 生成目标达成度等级统计表格
            % 表格包含：目标 | 完全达成 | 较好达成 | 基本达成 | 未达成 | 达成情况
            
            if ~obj.IsAnalysisComplete
                error('分析尚未完成，请先运行 runCompleteAnalysis()');
            end
            
            try
                % 获取权重数据
                weightData = obj.DatasetWeight;
                
                % 获取目标1~3的权重总分（权重值*100）
                targetWeightValues = table2array(weightData(end, 2:4)) * 100; % 合计行第2~4列
                
                % 计算学生总数
                totalStudents = height(obj.DatasetScore);
                
                % 创建结果表格
                obj.updateProgress('分析目标达成度等级...', 85);
                
                % 初始化结果数组
                resultData = cell(3, 6); % 3个目标 × 6列
                
                % 定义目标名称
                targetNames = {'目标1', '目标2', '目标3'};
                
                % 分析每个目标
                for target = 1:3
                    targetName = targetNames{target};
                    targetScore = targetWeightValues(target); % 该目标的总分
                    studentAchievements = obj.AchievementScores(:, target); % 学生在该目标上的得分
                    
                    % 计算每个学生在该目标上的达成度百分比
                    achievementRatios = studentAchievements / targetScore * 100;
                    
                    % 统计各达成等级的人数
                    completeCount = sum(achievementRatios >= 90); % 完全达成（90%以上）
                    goodCount = sum(achievementRatios >= 80 & achievementRatios < 90); % 较好达成（80%-90%）
                    basicCount = sum(achievementRatios >= 60 & achievementRatios < 80); % 基本达成（60%-80%）
                    failCount = sum(achievementRatios < 60); % 未达成（60%以下）
                    
                    % 计算达成情况
                    % （完全达成*4+较好达成*3+基本达成*2+未达成*1）/（总人数*4）
                    achievementLevel = (completeCount * 4 + goodCount * 3 + basicCount * 2 + failCount * 1) / (totalStudents * 4);
                    
                    % 填充结果数据
                    resultData{target, 1} = targetName;                                  % 目标
                    resultData{target, 2} = sprintf('%d (%.1f%%)', completeCount, completeCount/totalStudents*100); % 完全达成
                    resultData{target, 3} = sprintf('%d (%.1f%%)', goodCount, goodCount/totalStudents*100);         % 较好达成
                    resultData{target, 4} = sprintf('%d (%.1f%%)', basicCount, basicCount/totalStudents*100);       % 基本达成
                    resultData{target, 5} = sprintf('%d (%.1f%%)', failCount, failCount/totalStudents*100);         % 未达成
                    resultData{target, 6} = sprintf('%.3f (%.1f%%)', achievementLevel, achievementLevel*100);       % 达成情况
                end
                
                % 创建表格
                columnNames = {'目标', '完全达成', '较好达成', '基本达成', '未达成', '达成情况'};
                resultTable = cell2table(resultData, 'VariableNames', columnNames);
                
                % 保存到Excel文件
                outputFile = fullfile(obj.OutputDir, '目标达成度等级统计表.xlsx');
                writetable(resultTable, outputFile);
                
                % 将结果保存到类属性中
                obj.AnalysisResults.AchievementLevelTable = resultTable;
                
                % 更新进度
                obj.updateProgress('目标达成度等级统计表生成完成', 100);
                fprintf('目标达成度等级统计表已保存至：%s\n', outputFile);
                
            catch ME
                obj.updateProgress(['生成目标达成度等级统计表时出错: ' ME.message], -1);
                rethrow(ME);
            end
        end
    end
    
    methods (Access = private)
        function setupDefaultPaths(obj)
            % 设置默认文件路径
            currentDir = fileparts(mfilename('fullpath'));
            dataDir = fullfile(currentDir, 'data');
            
            obj.ScoreFile = fullfile(dataDir, '附件7-2023年2021级数学建模-期末考试成绩.xlsx');
            obj.WeightFile = fullfile(dataDir, '数学建模权重.xlsx');
            obj.OutputDir = fullfile(currentDir, 'output');
        end
        
        function initializeResults(obj)
            % 初始化结果结构
            obj.AnalysisResults = struct();
            obj.AnalysisResults.ScoreRanking = table();
            obj.AnalysisResults.AchievementAnalysis = table();
            obj.AnalysisResults.TargetSummary = table();
            obj.AnalysisResults.GradeSummary = table();
            obj.AnalysisResults.StatisticsSummary = struct();
        end
        
        function loadData(obj)
            % 加载成绩和权重数据
            
            % 读取成绩数据
            opts = detectImportOptions(obj.ScoreFile);
            opts.VariableNamingRule = 'preserve';
            opts.VariableNamesRange = "1:1";
            opts.DataRange = "A2:C79";
            opts.Sheet = 1;
            
            obj.DatasetScore = readtable(obj.ScoreFile, opts);
            
            % 获取表格尺寸
            temp1 = readtable(obj.WeightFile);   % 权重
            temp0 = readtable(obj.ScoreFile);    % 成绩
            [obj.M0, obj.N0] = size(temp1);
            [obj.M1, obj.N1] = size(temp0);
            
            % 读取权重数据
            opts = spreadsheetImportOptions("NumVariables", obj.N0);
            opts.VariableTypes{1} = 'char';
            opts.VariableNamingRule = 'preserve';
            for i = 2:obj.N0
                opts.VariableTypes{i} = 'double';
            end
            obj.DatasetWeight = readtable(obj.WeightFile, opts);
            
            obj.IsDataLoaded = true;
        end
        
        function validateWeights(obj)
            % 验证权重数据的正确性
            
            % 判断项目数是否匹配
            if obj.M0-1 ~= obj.N1
                error("源文件有误：项目数不匹配");
            end
            
            % 检查权重总和
            weightSum = sum(table2array(obj.DatasetWeight(2:end-1, 2:end-1)), 'all');
            
            if weightSum ~= 1 && weightSum ~= 100
                error("源文件有误：权重总和不是1或100");
            end
            
            % 判断目标1~3的和是否等于1
            data_target = zeros(1, 3);
            for i = 1:3
                data_target(i) = sum(table2array(obj.DatasetWeight(i+1, 2:end-1)), 'all');
            end
            data_targetSum = sum(data_target);
            
            if abs(data_targetSum - 1) > 1e-6
                error("源文件有误：目标1~3的权重和不等于1");
            end
        end
        
        function calculateTotalScores(obj)
            % 计算学生总成绩
            
            % 获取权重表的项目名称
            weightRows = obj.DatasetWeight(2:end, 1);
            projectNames = table2array(weightRows);
            
            % 定义有效项目名称
            validProjects = {'考勤', '平时作业', '期末考试'};
            
            % 检查项目名称
            for i = 1:length(validProjects)
                if ~strcmp(projectNames(i), validProjects{i})
                    error('权重表格中第 %d 行的项目名称不是 "%s"，请检查数据。', i, validProjects{i});
                end
            end
            
            % 提取权重值
            weights = table2array(obj.DatasetWeight(2:4, end));
            
            % 获取成绩表的列名
            scoreHeaders = obj.DatasetScore.Properties.VariableNames;
            [~, scoreColIndices] = ismember(validProjects, scoreHeaders);
            
            % 初始化总成绩数组
            totalScores = zeros(height(obj.DatasetScore), 1);
            
            % 计算每个学生的总成绩
            for i = 1:height(obj.DatasetScore)
                projectScores = table2array(obj.DatasetScore(i, scoreColIndices));
                weightedScore = projectScores * weights;
                totalScores(i) = weightedScore;
            end
            
            % 添加总成绩列
            obj.DatasetScore.TotalScore = totalScores;
            
            % 按总成绩降序排序
            obj.DatasetScore = sortrows(obj.DatasetScore, 'TotalScore', 'descend');
        end
        
        function calculateAchievementScores(obj)
            % 计算目标达成度
            
            % 获取权重表的项目名称
            weightRows = obj.DatasetWeight(2:end, 1);
            projectNames = table2array(weightRows);
            
            % 定义有效项目名称
            validProjects = {'考勤', '平时作业', '期末考试'};
            
            % 提取目标1~3的权重
            targetWeights = table2array(obj.DatasetWeight(2:4, 2:4));
            
            % 获取成绩表的列名
            scoreHeaders = obj.DatasetScore.Properties.VariableNames;
            [~, scoreColIndices] = ismember(validProjects, scoreHeaders);
            
            % 初始化达成度数组
            obj.AchievementScores = zeros(height(obj.DatasetScore), 3);
            
            % 计算每个学生的达成度
            for i = 1:height(obj.DatasetScore)
                projectScores = table2array(obj.DatasetScore(i, scoreColIndices));
                for j = 1:3
                    obj.AchievementScores(i, j) = projectScores * targetWeights(:, j);
                end
            end
            
            % 添加达成度列
            obj.DatasetScore.Achievement_Target1 = obj.AchievementScores(:, 1);
            obj.DatasetScore.Achievement_Target2 = obj.AchievementScores(:, 2);
            obj.DatasetScore.Achievement_Target3 = obj.AchievementScores(:, 3);
            
            % 重新排序
            obj.DatasetScore = sortrows(obj.DatasetScore, 'TotalScore', 'descend');
        end
        
        function assignGrades(obj)
            % 根据总成绩分配等级
            
            % 初始化 Grade 列
            obj.DatasetScore.Grade = strings(height(obj.DatasetScore), 1);
            
            % 分档逻辑
            for i = 1:height(obj.DatasetScore)
                score = obj.DatasetScore.TotalScore(i);
                if score >= 90
                    obj.DatasetScore.Grade(i) = "A";
                elseif score >= 80
                    obj.DatasetScore.Grade(i) = "B";
                elseif score >= 70
                    obj.DatasetScore.Grade(i) = "C";
                elseif score >= 60
                    obj.DatasetScore.Grade(i) = "D";
                else
                    obj.DatasetScore.Grade(i) = "E";
                end
            end
        end
        
        function saveResults(obj)
            % 保存所有分析结果
            
            % 1. 保存学生成绩排名
            outputFile1 = fullfile(obj.OutputDir, '学生成绩排名.xlsx');
            writetable(obj.DatasetScore, outputFile1);
            
            % 2. 保存学生成绩达成度分析
            outputFile2 = fullfile(obj.OutputDir, '学生成绩达成度分析.xlsx');
            writetable(obj.DatasetScore, outputFile2);
            
            % 3. 计算并保存目标达成度统计
            targetNames = {'目标1', '目标2', '目标3'};
            targetWeights = table2array(obj.DatasetWeight(end, 2:4)) * 100;
            averageAchievement = mean(obj.AchievementScores, 1);
            
            summaryTable = table('Size', [length(targetNames), 4], ...
                'VariableTypes', {'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'target', 'val', 'ave_score', 'ave_per'});
            
            for i = 1:length(targetNames)
                summaryTable.target(i) = i;
                summaryTable.val(i) = targetWeights(i);
                summaryTable.ave_score(i) = averageAchievement(i);
                summaryTable.ave_per(i) = averageAchievement(i) / summaryTable.val(i) * 100;
            end
            
            outputFile3 = fullfile(obj.OutputDir, '目标达成度分析.xlsx');
            writetable(summaryTable, outputFile3);
            
            % 4. 保存成绩等级分布
            grades = ["A", "B", "C", "D", "E"];
            gradeCounts = zeros(size(grades));
            for i = 1:length(grades)
                gradeCounts(i) = sum(strcmp(obj.DatasetScore.Grade, grades(i)));
            end
            
            gradeSummaryTable = table(grades', gradeCounts', ...
                'VariableNames', {'Grade', 'Count'});
            
            outputFile4 = fullfile(obj.OutputDir, '成绩等级分布.xlsx');
            writetable(obj.DatasetScore(:, {'TotalScore', 'Grade'}), outputFile4, 'Sheet', '成绩等级明细');
            writetable(gradeSummaryTable, outputFile4, 'Sheet', '等级人数统计', 'WriteMode', 'append');
            
            % 将结果保存到类属性中
            obj.AnalysisResults.ScoreRanking = obj.DatasetScore;
            obj.AnalysisResults.AchievementAnalysis = obj.DatasetScore;
            obj.AnalysisResults.TargetSummary = summaryTable;
            obj.AnalysisResults.GradeSummary = gradeSummaryTable;
        end
        
        function generateAnalysisReport(obj)
            % 生成分析统计摘要
            stats = struct();
            stats.TotalStudents = height(obj.DatasetScore);
            stats.AvgScore = mean(obj.DatasetScore.TotalScore);
            stats.MaxScore = max(obj.DatasetScore.TotalScore);
            stats.MinScore = min(obj.DatasetScore.TotalScore);
            stats.StdScore = std(obj.DatasetScore.TotalScore);
            
            % 等级分布百分比
            grades = ["A", "B", "C", "D", "E"];
            gradePercents = zeros(size(grades));
            for i = 1:length(grades)
                gradePercents(i) = sum(strcmp(obj.DatasetScore.Grade, grades(i))) / stats.TotalStudents * 100;
            end
            stats.GradeDistribution = containers.Map(cellstr(grades), num2cell(gradePercents));
            
            obj.AnalysisResults.StatisticsSummary = stats;
        end
        
        function updateProgress(obj, message, percentage)
            % 更新进度
            if ~isempty(obj.ProgressCallback)
                obj.ProgressCallback(message, percentage);
            else
                % 默认输出到命令窗口
                if percentage >= 0
                    fprintf('[%3.0f%%] %s\n', percentage, message);
                else
                    fprintf('[错误] %s\n', message);
                end
            end
        end
    end
end 