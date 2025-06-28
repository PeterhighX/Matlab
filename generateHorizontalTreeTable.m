function generateHorizontalTreeTable()
    % 生成横向树状表格
    % 表格包含：目标 | 评价方式 | 权重 | 总分值 | 平均得分 | 达成情况
    % 
    % 使用方法：
    %   generateHorizontalTreeTable();  % 使用默认路径
    
    fprintf('开始生成横向树状表格...\n');
    
    try
        % 设置默认路径
        currentDir = fileparts(mfilename('fullpath'));
        dataDir = fullfile(currentDir, 'data');
        outputDir = fullfile(currentDir, 'output');
        
        scoreFile = fullfile(dataDir, '附件7-2023年2021级数学建模-期末考试成绩.xlsx');
        weightFile = fullfile(dataDir, '数学建模权重.xlsx');
        
        % 检查必要文件是否存在
        if ~exist(scoreFile, 'file')
            error('成绩文件不存在：%s', scoreFile);
        end
        if ~exist(weightFile, 'file')
            error('权重文件不存在：%s', weightFile);
        end
        if ~exist(outputDir, 'dir')
            error('输出目录不存在：%s\n请先运行分析生成必要的数据文件', outputDir);
        end
        
        % 读取权重数据
        fprintf('读取权重数据...\n');
        weightData = readtable(weightFile, 'VariableNamingRule', 'preserve');
        
        % 直接设置目标名称为目标1~3
        targetHeaders = {'目标1', '目标2', '目标3'};
        
        % 获取评价方式名称（第2-4行，第1列）
        evaluationMethods = table2array(weightData(2:4, 1));
        
        % 获取权重值（第2-4行，第2-4列）
        weightValues = table2array(weightData(2:4, 2:4));
        
        % 读取目标达成度数据
        fprintf('读取目标达成度数据...\n');
        targetFile = fullfile(outputDir, '目标达成度分析.xlsx');
        if ~exist(targetFile, 'file')
            error('目标达成度分析文件不存在：%s\n请先运行完整分析', targetFile);
        end
        
        targetSummary = readtable(targetFile);
        avePerValues = targetSummary.ave_per; % 达成情况百分比
        aveScoreValues = targetSummary.ave_score; % 平均得分
        
        % 读取学生成绩达成度分析数据（用于计算各评价方式的平均得分）
        fprintf('读取学生达成度数据...\n');
        achievementFile = fullfile(outputDir, '学生成绩达成度分析.xlsx');
        if ~exist(achievementFile, 'file')
            error('学生达成度分析文件不存在：%s\n请先运行完整分析', achievementFile);
        end
        
        achievementData = readtable(achievementFile);
        
        % 提取Achievement_Target1~3列
        achievementCols = [];
        for i = 1:3
            colName = sprintf('Achievement_Target%d', i);
            if ismember(colName, achievementData.Properties.VariableNames)
                achievementCols = [achievementCols, achievementData.(colName)];
            else
                error('找不到列：%s', colName);
            end
        end
        
        % 计算每个目标的平均达成分数
        avgTargetScores = mean(achievementCols, 1);
        
        % 创建结果表格
        fprintf('生成横向树状表格...\n');
        numRows = 3 * length(evaluationMethods); % 3个目标 × 3个评价方式
        
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
                
                % 平均得分（基于权重占比计算）
                % 获取该评价方式在当前目标中的权重占比
                targetTotalWeight = sum(weightValues(:, target));
                if targetTotalWeight > 0
                    methodRatio = weight / targetTotalWeight;
                    avgScore = avgTargetScores(target) * methodRatio;
                else
                    avgScore = 0;
                end
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
        outputFile = fullfile(outputDir, '目标评价横向树状表.xlsx');
        writetable(resultTable, outputFile);
        
        fprintf('✓ 横向树状表格已生成并保存至：%s\n', outputFile);
        
        % 显示表格内容
        fprintf('\n=== 横向树状表格内容 ===\n');
        disp(resultTable);
        
    catch ME
        fprintf('✗ 生成横向树状表格时出错：%s\n', ME.message);
        rethrow(ME);
    end
end 