% 测试类封装版本的成绩分析系统

function test_analysis_class()
    % 创建分析对象
    analyzer = GradeAnalysisClass();
    
    % 设置进度回调（可选）
    analyzer.setProgressCallback(@progressCallback);
    
    % 运行完整分析
    success = analyzer.runCompleteAnalysis();
    
    if success
        % 获取各种数据
        scoreData = analyzer.getScoreData();        % 获取成绩数据
        weightData = analyzer.getWeightData();      % 获取权重数据
        results = analyzer.getResults();            % 获取完整结果
        gradeSummary = analyzer.getGradeSummary();  % 获取等级摘要
        
        % 将变量导出到base workspace
        assignin('base', 'scoreData', scoreData);
        assignin('base', 'weightData', weightData);
        assignin('base', 'results', results);
        assignin('base', 'gradeSummary', gradeSummary);
        assignin('base', 'analyzer', analyzer);  % 导出分析器对象本身
        
        % 现在这些变量会出现在workspace中
        fprintf('变量已导出到workspace:\n');
        evalin('base', 'whos');  % 在base workspace中执行whos
        
        % 显示分析摘要
        stats = results.StatisticsSummary;
        fprintf('\n=== 分析结果摘要 ===\n');
        fprintf('学生总数: %d\n', stats.TotalStudents);
        fprintf('平均分: %.2f\n', stats.AvgScore);
        fprintf('最高分: %.2f\n', stats.MaxScore);
        fprintf('最低分: %.2f\n', stats.MinScore);
        fprintf('标准差: %.2f\n', stats.StdScore);
        
        fprintf('\n等级分布:\n');
        grades = keys(stats.GradeDistribution);
        for i = 1:length(grades)
            fprintf('  %s级: %.1f%%\n', grades{i}, stats.GradeDistribution(grades{i}));
        end
        
        fprintf('\n所有结果已保存到 output 文件夹\n');
    else
        fprintf('分析失败！\n');
    end
end

function progressCallback(message, percentage)
    % 进度回调函数
    if percentage >= 0
        fprintf('[%3.0f%%] %s\n', percentage, message);
    else
        fprintf('[错误] %s\n', message);
    end
end 