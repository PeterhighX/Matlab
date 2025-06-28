function generateAchievementLevelTable()
    % 生成目标达成度等级统计表格
    % 表格包含：目标 | 完全达成 | 较好达成 | 基本达成 | 未达成 | 达成情况
    % 
    % 使用方法：
    %   generateAchievementLevelTable();  % 使用默认路径
    
    fprintf('开始生成目标达成度等级统计表格...\n');
    
    try
        % 设置默认路径
        currentDir = fileparts(mfilename('fullpath'));
        dataDir = fullfile(currentDir, 'data');
        outputDir = fullfile(currentDir, 'output');
        
        weightFile = fullfile(dataDir, '数学建模权重.xlsx');
        
        % 检查必要文件是否存在
        if ~exist(weightFile, 'file')
            error('权重文件不存在：%s', weightFile);
        end
        if ~exist(outputDir, 'dir')
            error('输出目录不存在：%s\n请先运行分析生成必要的数据文件', outputDir);
        end
        
        % 读取权重数据
        fprintf('读取权重数据...\n');
        weightData = readtable(weightFile, 'VariableNamingRule', 'preserve');
        
        % 获取目标1~3的权重总分（权重值*100）
        targetWeightValues = table2array(weightData(end, 2:4)) * 100; % 合计行第2~4列
        
        % 读取学生成绩达成度分析数据
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
        
        % 计算学生总数
        totalStudents = height(achievementData);
        
        % 创建结果表格
        fprintf('分析目标达成度等级...\n');
        
        % 初始化结果数组
        resultData = cell(3, 6); % 3个目标 × 6列
        
        % 定义目标名称
        targetNames = {'目标1', '目标2', '目标3'};
        
        % 分析每个目标
        for target = 1:3
            targetName = targetNames{target};
            targetScore = targetWeightValues(target); % 该目标的总分
            studentAchievements = achievementCols(:, target); % 学生在该目标上的得分
            
            % 计算每个学生在该目标上的达成度百分比
            achievementRatios = studentAchievements / targetScore * 100;
            
            % 统计各达成等级的人数
            completeCount = sum(achievementRatios >= 90); % 完全达成（90%以上）
            goodCount = sum(achievementRatios >= 80 & achievementRatios < 90); % 较好达成（80%-90%）
            basicCount = sum(achievementRatios >= 60 & achievementRatios < 80); % 基本达成（60%-80%）
            failCount = sum(achievementRatios < 60); % 未达成（60%以下）
            
            % 验证人数统计
            if (completeCount + goodCount + basicCount + failCount) ~= totalStudents
                warning('目标%d的人数统计有误！', target);
            end
            
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
            
            % 显示详细统计信息
            fprintf('  %s (总分%.1f):\n', targetName, targetScore);
            fprintf('    完全达成(≥90%%): %d人 (%.1f%%)\n', completeCount, completeCount/totalStudents*100);
            fprintf('    较好达成(80-90%%): %d人 (%.1f%%)\n', goodCount, goodCount/totalStudents*100);
            fprintf('    基本达成(60-80%%): %d人 (%.1f%%)\n', basicCount, basicCount/totalStudents*100);
            fprintf('    未达成(<60%%): %d人 (%.1f%%)\n', failCount, failCount/totalStudents*100);
            fprintf('    综合达成情况: %.3f (%.1f%%)\n', achievementLevel, achievementLevel*100);
            fprintf('\n');
        end
        
        % 创建表格
        columnNames = {'目标', '完全达成', '较好达成', '基本达成', '未达成', '达成情况'};
        resultTable = cell2table(resultData, 'VariableNames', columnNames);
        
        % 保存到Excel文件
        outputFile = fullfile(outputDir, '目标达成度等级统计表.xlsx');
        writetable(resultTable, outputFile);
        
        fprintf('✓ 目标达成度等级统计表已生成并保存至：%s\n', outputFile);
        
        % 显示表格内容
        fprintf('\n=== 目标达成度等级统计表 ===\n');
        disp(resultTable);
        
        % 显示总体统计
        fprintf('\n=== 总体统计 ===\n');
        fprintf('学生总数: %d人\n', totalStudents);
        
        % 计算各等级总体分布
        allAchievementRatios = [];
        for target = 1:3
            targetScore = targetWeightValues(target);
            studentAchievements = achievementCols(:, target);
            achievementRatios = studentAchievements / targetScore * 100;
            allAchievementRatios = [allAchievementRatios; achievementRatios];
        end
        
        totalComplete = sum(allAchievementRatios >= 90);
        totalGood = sum(allAchievementRatios >= 80 & allAchievementRatios < 90);
        totalBasic = sum(allAchievementRatios >= 60 & allAchievementRatios < 80);
        totalFail = sum(allAchievementRatios < 60);
        totalSamples = length(allAchievementRatios);
        
        fprintf('总体达成度分布（基于%d个样本）:\n', totalSamples);
        fprintf('  完全达成: %d (%.1f%%)\n', totalComplete, totalComplete/totalSamples*100);
        fprintf('  较好达成: %d (%.1f%%)\n', totalGood, totalGood/totalSamples*100);
        fprintf('  基本达成: %d (%.1f%%)\n', totalBasic, totalBasic/totalSamples*100);
        fprintf('  未达成: %d (%.1f%%)\n', totalFail, totalFail/totalSamples*100);
        
        overallAchievement = (totalComplete * 4 + totalGood * 3 + totalBasic * 2 + totalFail * 1) / (totalSamples * 4);
        fprintf('  总体达成情况: %.3f (%.1f%%)\n', overallAchievement, overallAchievement*100);
        
    catch ME
        fprintf('✗ 生成目标达成度等级统计表时出错：%s\n', ME.message);
        rethrow(ME);
    end
end 