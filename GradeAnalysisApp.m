function GradeAnalysisApp()
% GRADEANALYSISAPP 成绩分析系统主界面
% 基于GradeAnalysisClass的图形用户界面

    % 创建主窗口 - 添加现代化外观
    fig = uifigure('Name', '成绩分析系统', 'Position', [100, 100, 1000, 700], ...
                   'Resize', 'on', 'WindowState', 'normal');
    
    % 应用数据
    appData = struct();
    appData.analyzer = [];
    appData.isAnalysisComplete = false;
    
    % 创建主布局 - 添加间距和内边距
    mainGrid = uigridlayout(fig, [1, 2]);
    mainGrid.ColumnWidth = {300, '1x'};
    mainGrid.Padding = [10, 10, 10, 10];
    mainGrid.RowSpacing = 10;
    mainGrid.ColumnSpacing = 10;
    
    %% 左侧控制面板 - 圆角边框和背景色
    leftPanel = uipanel(mainGrid, 'Title', '控制面板', 'BorderType', 'line', ...
                       'HighlightColor', [0.7, 0.7, 0.7], 'BackgroundColor', [0.98, 0.98, 0.98]);
    leftPanel.Layout.Row = 1;
    leftPanel.Layout.Column = 1;
    
    % 文件选择区域 - 蓝色主题圆角边框
    filePanel = uipanel(leftPanel, 'Title', '文件选择', 'Position', [10, 480, 280, 180], ...
                       'BorderType', 'line', 'HighlightColor', [0.5, 0.8, 1.0], ...
                       'BackgroundColor', [0.98, 0.99, 1.0]);
    
    % 成绩文件
    scoreFileLabel = uilabel(filePanel, 'Text', '成绩文件:', 'Position', [10, 140, 100, 22]);
    scoreFileField = uieditfield(filePanel, 'text', 'Position', [10, 115, 180, 22]);
    scoreFileBrowseBtn = uibutton(filePanel, 'push', 'Text', '浏览', 'Position', [200, 115, 60, 22], ...
                                 'BackgroundColor', [0.9, 0.95, 1.0]);
    scoreFileBrowseBtn.ButtonPushedFcn = @(src, event) browseScoreFile();
    
    % 权重文件
    weightFileLabel = uilabel(filePanel, 'Text', '权重文件:', 'Position', [10, 85, 100, 22]);
    weightFileField = uieditfield(filePanel, 'text', 'Position', [10, 60, 180, 22]);
    weightFileBrowseBtn = uibutton(filePanel, 'push', 'Text', '浏览', 'Position', [200, 60, 60, 22], ...
                                  'BackgroundColor', [0.9, 0.95, 1.0]);
    weightFileBrowseBtn.ButtonPushedFcn = @(src, event) browseWeightFile();
    
    % 输出目录
    outputDirLabel = uilabel(filePanel, 'Text', '输出目录:', 'Position', [10, 30, 100, 22]);
    outputDirField = uieditfield(filePanel, 'text', 'Position', [10, 5, 180, 22]);
    outputDirBrowseBtn = uibutton(filePanel, 'push', 'Text', '浏览', 'Position', [200, 5, 60, 22], ...
                                 'BackgroundColor', [0.9, 0.95, 1.0]);
    outputDirBrowseBtn.ButtonPushedFcn = @(src, event) browseOutputDir();
    
    % 操作控制区域 - 绿色主题圆角边框
    controlPanel = uipanel(leftPanel, 'Title', '操作控制', 'Position', [10, 350, 280, 130], ...
                          'BorderType', 'line', 'HighlightColor', [0.5, 0.9, 0.5], ...
                          'BackgroundColor', [0.98, 1.0, 0.98]);
    
    runAnalysisBtn = uibutton(controlPanel, 'push', 'Text', '开始分析', ...
                             'Position', [10, 70, 260, 35], 'FontWeight', 'bold', ...
                             'BackgroundColor', [0.2, 0.7, 0.2], 'FontColor', 'white');
    runAnalysisBtn.ButtonPushedFcn = @(src, event) runAnalysis();
    
    resetBtn = uibutton(controlPanel, 'push', 'Text', '重置', 'Position', [10, 25, 125, 30], ...
                       'BackgroundColor', [0.9, 0.9, 0.9], 'FontColor', [0.3, 0.3, 0.3]);
    resetBtn.ButtonPushedFcn = @(src, event) resetApp();
    
    exportBtn = uibutton(controlPanel, 'push', 'Text', '导出结果', ...
                        'Position', [145, 25, 125, 30], 'Enable', 'off', ...
                        'BackgroundColor', [0.2, 0.5, 0.8], 'FontColor', 'white');
    exportBtn.ButtonPushedFcn = @(src, event) exportResults();
    
    % 进度显示区域 - 橙色主题圆角边框
    progressPanel = uipanel(leftPanel, 'Title', '进度状态', 'Position', [10, 40, 280, 300], ...
                           'BorderType', 'line', 'HighlightColor', [1.0, 0.7, 0.3], ...
                           'BackgroundColor', [1.0, 0.99, 0.96]);
    
    progressLabel = uilabel(progressPanel, 'Text', '就绪', 'FontWeight', 'bold', ...
                           'Position', [10, 260, 260, 22], 'FontColor', [0.3, 0.3, 0.3]);
    
    progressGauge = uigauge(progressPanel, 'linear', 'Limits', [0, 100], ...
                           'Position', [10, 230, 260, 25], 'ScaleColors', [0.2, 0.7, 0.2]);
    
    statusArea = uitextarea(progressPanel, 'Position', [10, 10, 260, 210], ...
                           'Editable', 'off', 'Value', {'欢迎使用成绩分析系统！'}, ...
                           'BackgroundColor', [1.0, 1.0, 1.0]);
    
    %% 右侧结果显示面板 - 圆角边框
    rightPanel = uipanel(mainGrid, 'Title', '结果显示', 'BorderType', 'line', ...
                        'HighlightColor', [0.7, 0.7, 0.7], 'BackgroundColor', [0.98, 0.98, 0.98]);
    rightPanel.Layout.Row = 1;
    rightPanel.Layout.Column = 2;
    
    resultsTabGroup = uitabgroup(rightPanel, 'Position', [10, 10, 660, 650]);
    
    % 概览统计标签页
    overviewTab = uitab(resultsTabGroup, 'Title', '概览统计');
    
    statsLabel1 = uilabel(overviewTab, 'Text', '学生总数: --', 'FontSize', 14, ...
                          'Position', [20, 580, 300, 22]);
    statsLabel2 = uilabel(overviewTab, 'Text', '平均分: --', 'FontSize', 14, ...
                          'Position', [20, 540, 300, 22]);
    statsLabel3 = uilabel(overviewTab, 'Text', '最高分: --', 'FontSize', 14, ...
                          'Position', [20, 500, 300, 22]);
    statsLabel4 = uilabel(overviewTab, 'Text', '最低分: --', 'FontSize', 14, ...
                          'Position', [20, 460, 300, 22]);
    statsLabel5 = uilabel(overviewTab, 'Text', '标准差: --', 'FontSize', 14, ...
                          'Position', [20, 420, 300, 22]);
    
    % 成绩排名标签页
    scoreRankingTab = uitab(resultsTabGroup, 'Title', '成绩排名');
    scoreTable = uitable(scoreRankingTab, 'Position', [10, 10, 620, 600]);
    
    % 等级分布标签页
    gradeDistTab = uitab(resultsTabGroup, 'Title', '等级分布');
    gradeChart = uiaxes(gradeDistTab, 'Position', [10, 320, 620, 290]);
    title(gradeChart, '等级分布');
    gradeTable = uitable(gradeDistTab, 'Position', [10, 10, 620, 300]);
    
    % 达成度分析标签页
    achievementTab = uitab(resultsTabGroup, 'Title', '达成度分析');
    achievementChart = uiaxes(achievementTab, 'Position', [10, 320, 620, 290]);
    title(achievementChart, '目标达成度');
    xlabel(achievementChart, '课程目标');
    ylabel(achievementChart, '达成度 (%)');
    achievementTable = uitable(achievementTab, 'Position', [10, 10, 620, 300]);
    
    %% 初始化
    setupDefaultValues();
    
    %% 回调函数
    
    function setupDefaultValues()
        % 设置默认文件路径
        currentDir = pwd;
        dataDir = fullfile(currentDir, 'data');
        
        if exist(dataDir, 'dir')
            scoreFile = fullfile(dataDir, '附件7-2023年2021级数学建模-期末考试成绩.xlsx');
            weightFile = fullfile(dataDir, '数学建模权重.xlsx');
            
            if exist(scoreFile, 'file')
                scoreFileField.Value = scoreFile;
            end
            if exist(weightFile, 'file')
                weightFileField.Value = weightFile;
            end
        end
        
        outputDirField.Value = fullfile(currentDir, 'output');
    end
    
    function browseScoreFile()
        [file, path] = uigetfile({'*.xlsx;*.xls', 'Excel文件'}, '选择成绩文件');
        if file ~= 0
            scoreFileField.Value = fullfile(path, file);
        end
    end
    
    function browseWeightFile()
        [file, path] = uigetfile({'*.xlsx;*.xls', 'Excel文件'}, '选择权重文件');
        if file ~= 0
            weightFileField.Value = fullfile(path, file);
        end
    end
    
    function browseOutputDir()
        folder = uigetdir(pwd, '选择输出目录');
        if folder ~= 0
            outputDirField.Value = folder;
        end
    end
    
    function runAnalysis()
        try
            % 禁用按钮
            runAnalysisBtn.Enable = 'off';
            runAnalysisBtn.Text = '分析中...';
            
            % 验证输入
            if ~validateInputs()
                return;
            end
            
            % 创建分析器对象 - 直接调用GradeAnalysisClass
            appData.analyzer = GradeAnalysisClass(scoreFileField.Value, ...
                                                 weightFileField.Value, ...
                                                 outputDirField.Value);
            
            % 设置进度回调
            appData.analyzer.setProgressCallback(@updateProgress);
            
            % 清空状态
            statusArea.Value = {''};
            
            % 运行完整分析
            success = appData.analyzer.runCompleteAnalysis();
            
            if success
                appData.isAnalysisComplete = true;
                displayResults();
                exportBtn.Enable = 'on';
                addStatusMessage('✓ 分析完成！所有结果已保存。');
            else
                addStatusMessage('✗ 分析失败！');
            end
            
        catch ME
            addStatusMessage(['✗ 错误: ' ME.message]);
        finally
            % 恢复按钮
            runAnalysisBtn.Enable = 'on';
            runAnalysisBtn.Text = '开始分析';
        end
    end
    
    function resetApp()
        progressGauge.Value = 0;
        progressLabel.Text = '就绪';
        statusArea.Value = {''};
        appData.isAnalysisComplete = false;
        exportBtn.Enable = 'off';
        clearResults();
        addStatusMessage('界面已重置');
    end
    
    function exportResults()
        if ~appData.isAnalysisComplete
            uialert(fig, '请先完成分析', '提示');
            return;
        end
        
        try
            % 获取结果 - 直接调用GradeAnalysisClass的方法
            results = appData.analyzer.getResults();
            scoreData = appData.analyzer.getScoreData();
            weightData = appData.analyzer.getWeightData();
            gradeSummary = appData.analyzer.getGradeSummary();
            
            % 导出到工作区
            assignin('base', 'analysisResults', results);
            assignin('base', 'analyzer', appData.analyzer);
            assignin('base', 'scoreData', scoreData);
            assignin('base', 'weightData', weightData);
            assignin('base', 'gradeSummary', gradeSummary);
            
            addStatusMessage('✓ 结果已导出到MATLAB工作区');
            uialert(fig, '分析结果已导出到工作区变量：analysisResults, analyzer, scoreData, weightData, gradeSummary', ...
                   '导出成功', 'Icon', 'success');
            
        catch ME
            uialert(fig, ['导出失败: ' ME.message], '错误');
        end
    end
    
    function valid = validateInputs()
        valid = true;
        
        if isempty(scoreFileField.Value) || ~exist(scoreFileField.Value, 'file')
            uialert(fig, '请选择有效的成绩文件', '输入错误');
            valid = false;
            return;
        end
        
        if isempty(weightFileField.Value) || ~exist(weightFileField.Value, 'file')
            uialert(fig, '请选择有效的权重文件', '输入错误');
            valid = false;
            return;
        end
        
        if isempty(outputDirField.Value)
            uialert(fig, '请选择输出目录', '输入错误');
            valid = false;
            return;
        end
    end
    
    function updateProgress(message, percentage)
        % 进度回调函数
        if percentage >= 0
            progressGauge.Value = percentage;
            progressLabel.Text = sprintf('%d%% - %s', round(percentage), message);
        else
            progressLabel.Text = sprintf('错误 - %s', message);
        end
        
        addStatusMessage(sprintf('[%s] %s', datestr(now, 'HH:MM:SS'), message));
        drawnow;
    end
    
    function addStatusMessage(message)
        currentMessages = statusArea.Value;
        newMessages = [currentMessages; {message}];
        
        % 保持最近20条消息
        if length(newMessages) > 20
            newMessages = newMessages(end-19:end);
        end
        
        statusArea.Value = newMessages;
    end
    
    function displayResults()
        if ~appData.isAnalysisComplete
            return;
        end
        
        try
            % 获取分析结果
            results = appData.analyzer.getResults();
            stats = results.StatisticsSummary;
            
            % 更新概览统计
            statsLabel1.Text = sprintf('学生总数: %d', stats.TotalStudents);
            statsLabel2.Text = sprintf('平均分: %.2f', stats.AvgScore);
            statsLabel3.Text = sprintf('最高分: %.2f', stats.MaxScore);
            statsLabel4.Text = sprintf('最低分: %.2f', stats.MinScore);
            statsLabel5.Text = sprintf('标准差: %.2f', stats.StdScore);
            
            % 更新成绩排名表
            scoreData = appData.analyzer.getScoreData();
            scoreTable.Data = table2array(scoreData);
            scoreTable.ColumnName = scoreData.Properties.VariableNames;
            
            % 更新等级分布
            gradeSummary = results.GradeSummary;
            cla(gradeChart);
            pie(gradeChart, gradeSummary.Count, cellstr(gradeSummary.Grade));
            title(gradeChart, '等级分布');
            gradeTable.Data = table2array(gradeSummary);
            gradeTable.ColumnName = gradeSummary.Properties.VariableNames;
            
            % 更新达成度分析
            targetSummary = results.TargetSummary;
            cla(achievementChart);
            bar(achievementChart, targetSummary.target, targetSummary.ave_per);
            title(achievementChart, '目标达成度');
            xlabel(achievementChart, '课程目标');
            ylabel(achievementChart, '达成度 (%)');
            grid(achievementChart, 'on');
            achievementTable.Data = table2array(targetSummary);
            achievementTable.ColumnName = targetSummary.Properties.VariableNames;
            
        catch ME
            addStatusMessage(['显示结果时出错: ' ME.message]);
        end
    end
    
    function clearResults()
        statsLabel1.Text = '学生总数: --';
        statsLabel2.Text = '平均分: --';
        statsLabel3.Text = '最高分: --';
        statsLabel4.Text = '最低分: --';
        statsLabel5.Text = '标准差: --';
        
        scoreTable.Data = {};
        gradeTable.Data = {};
        achievementTable.Data = {};
        
        cla(gradeChart);
        cla(achievementChart);
    end

end 