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
    mainGrid.ColumnWidth = {380, '1x'};
    mainGrid.Padding = [10, 10, 10, 10];
    mainGrid.RowSpacing = 10;
    mainGrid.ColumnSpacing = 10;
    
    %% 左侧控制面板 - 响应式网格布局
    leftPanel = uipanel(mainGrid, 'Title', '控制面板', 'BorderType', 'line', ...
                       'HighlightColor', [0.7, 0.7, 0.7], 'BackgroundColor', [0.98, 0.98, 0.98]);
    leftPanel.Layout.Row = 1;
    leftPanel.Layout.Column = 1;
    
    % 创建左侧面板的网格布局
    leftGrid = uigridlayout(leftPanel, [4, 1]);
    leftGrid.RowHeight = {130, 260, 105, '1x'};  % 文件选择，权重编辑，操作控制，进度状态
    leftGrid.Padding = [10, 10, 10, 10];
    leftGrid.RowSpacing = 5;
    
    % 文件选择区域 - 响应式面板
    filePanel = uipanel(leftGrid, 'Title', '文件选择', ...
                       'BorderType', 'line', 'HighlightColor', [0.5, 0.8, 1.0], ...
                       'BackgroundColor', [0.98, 0.99, 1.0]);
    filePanel.Layout.Row = 1;
    filePanel.Layout.Column = 1;
    
    % 文件选择区域内部网格布局
    fileGrid = uigridlayout(filePanel, [3, 3]);
    fileGrid.ColumnWidth = {80, '1x', 60};  % 标签，输入框，按钮
    fileGrid.RowHeight = {25, 25, 25};
    fileGrid.Padding = [10, 10, 10, 10];
    fileGrid.RowSpacing = 5;
    fileGrid.ColumnSpacing = 5;
    
    % 成绩文件
    scoreFileLabel = uilabel(fileGrid, 'Text', '成绩文件:');
    scoreFileLabel.Layout.Row = 1;
    scoreFileLabel.Layout.Column = 1;
    
    scoreFileField = uieditfield(fileGrid, 'text');
    scoreFileField.Layout.Row = 1;
    scoreFileField.Layout.Column = 2;
    
    scoreFileBrowseBtn = uibutton(fileGrid, 'push', 'Text', '浏览', ...
                                 'BackgroundColor', [0.9, 0.95, 1.0]);
    scoreFileBrowseBtn.Layout.Row = 1;
    scoreFileBrowseBtn.Layout.Column = 3;
    scoreFileBrowseBtn.ButtonPushedFcn = @(src, event) browseScoreFile();
    
    % 权重文件
    weightFileLabel = uilabel(fileGrid, 'Text', '权重文件:');
    weightFileLabel.Layout.Row = 2;
    weightFileLabel.Layout.Column = 1;
    
    weightFileField = uieditfield(fileGrid, 'text');
    weightFileField.Layout.Row = 2;
    weightFileField.Layout.Column = 2;
    weightFileField.ValueChangedFcn = @(src, event) onWeightFileChanged();
    
    weightFileBrowseBtn = uibutton(fileGrid, 'push', 'Text', '浏览', ...
                                  'BackgroundColor', [0.9, 0.95, 1.0]);
    weightFileBrowseBtn.Layout.Row = 2;
    weightFileBrowseBtn.Layout.Column = 3;
    weightFileBrowseBtn.ButtonPushedFcn = @(src, event) browseWeightFile();
    
    % 输出目录
    outputDirLabel = uilabel(fileGrid, 'Text', '输出目录:');
    outputDirLabel.Layout.Row = 3;
    outputDirLabel.Layout.Column = 1;
    
    outputDirField = uieditfield(fileGrid, 'text');
    outputDirField.Layout.Row = 3;
    outputDirField.Layout.Column = 2;
    
    outputDirBrowseBtn = uibutton(fileGrid, 'push', 'Text', '浏览', ...
                                 'BackgroundColor', [0.9, 0.95, 1.0]);
    outputDirBrowseBtn.Layout.Row = 3;
    outputDirBrowseBtn.Layout.Column = 3;
    outputDirBrowseBtn.ButtonPushedFcn = @(src, event) browseOutputDir();
    
    %% 权重编辑区域 - 响应式面板
    weightPanel = uipanel(leftGrid, 'Title', '权重编辑', ...
                         'BorderType', 'line', 'HighlightColor', [0.8, 0.5, 1.0], ...
                         'BackgroundColor', [0.99, 0.98, 1.0]);
    weightPanel.Layout.Row = 2;
    weightPanel.Layout.Column = 1;
    
    % 权重编辑区域内部网格布局
    weightGrid = uigridlayout(weightPanel, [3, 1]);
    weightGrid.RowHeight = {35, 30, '1x'};  % 控制行，模式选择行，表格
    weightGrid.Padding = [10, 10, 10, 10];
    weightGrid.RowSpacing = 5;
    
    % 顶部控制区域
    topControlGrid = uigridlayout(weightGrid, [1, 4]);
    topControlGrid.ColumnWidth = {120, '1x', 50, 50};
    topControlGrid.ColumnSpacing = 5;
    topControlGrid.Layout.Row = 1;
    topControlGrid.Layout.Column = 1;
    
    % 权重数据来源标签
    weightModeLabel = uilabel(topControlGrid, 'Text', '权重数据来源:', 'FontSize', 10);
    weightModeLabel.Layout.Row = 1;
    weightModeLabel.Layout.Column = 1;
    
    % 占位符（为了对齐）
    spacer = uilabel(topControlGrid, 'Text', '');
    spacer.Layout.Row = 1;
    spacer.Layout.Column = 2;
    
    % 权重表格控制按钮
    loadWeightBtn = uibutton(topControlGrid, 'push', 'Text', '加载', ...
                            'BackgroundColor', [0.9, 0.9, 1.0], 'FontSize', 9);
    loadWeightBtn.Layout.Row = 1;
    loadWeightBtn.Layout.Column = 3;
    loadWeightBtn.ButtonPushedFcn = @(src, event) loadWeightData();
    
    saveWeightBtn = uibutton(topControlGrid, 'push', 'Text', '保存', ...
                            'BackgroundColor', [0.9, 0.9, 1.0], 'FontSize', 9);
    saveWeightBtn.Layout.Row = 1;
    saveWeightBtn.Layout.Column = 4;
    saveWeightBtn.ButtonPushedFcn = @(src, event) saveWeightData();
    
    % 权重数据模式选择
    weightModeGroup = uibuttongroup(weightGrid, ...
                                   'BackgroundColor', [0.99, 0.98, 1.0]);
    weightModeGroup.Layout.Row = 2;
    weightModeGroup.Layout.Column = 1;
    
    % 直接在ButtonGroup中使用Position定位（ButtonGroup不支持uigridlayout）
    weightFromFileBtn = uiradiobutton(weightModeGroup, 'Text', '从文件读取', ...
                                     'Position', [15, 5, 90, 20]);
    
    weightFromTableBtn = uiradiobutton(weightModeGroup, 'Text', '手动编辑', ...
                                      'Position', [120, 5, 90, 20]);
    
    weightModeGroup.SelectedObject = weightFromFileBtn; % 默认选择文件模式
    
    % 权重表格
    weightTable = uitable(weightGrid, ...
                         'ColumnEditable', [false, true, true, true, false], ...
                         'Enable', 'off');
    weightTable.Layout.Row = 3;
    weightTable.Layout.Column = 1;
    
    % 权重模式切换回调
    weightModeGroup.SelectionChangedFcn = @(src, event) switchWeightMode();
    
    %%  操作控制区域 - 响应式面板
    controlPanel = uipanel(leftGrid, 'Title', '', ...
                          'BorderType', 'none', ...
                          'BackgroundColor', [0.98, 0.98, 0.98]);
    controlPanel.Layout.Row = 3;
    controlPanel.Layout.Column = 1;
    
    % 操作控制内部网格布局
    controlGrid = uigridlayout(controlPanel, [3, 2]);
    controlGrid.RowHeight = {35, 25, 35};
    controlGrid.ColumnWidth = {'1x', '1x'};
    controlGrid.Padding = [10, 5, 10, 5];
    controlGrid.RowSpacing = 5;
    controlGrid.ColumnSpacing = 5;
    
    runAnalysisBtn = uibutton(controlGrid, 'push', 'Text', '开始分析', ...
                             'FontWeight', 'bold', ...
                             'BackgroundColor', [0.2, 0.7, 0.2], 'FontColor', 'white');
    runAnalysisBtn.Layout.Row = 1;
    runAnalysisBtn.Layout.Column = [1, 2];  % 跨两列
    runAnalysisBtn.ButtonPushedFcn = @(src, event) runAnalysis();
    
    resetBtn = uibutton(controlGrid, 'push', 'Text', '重置', ...
                       'BackgroundColor', [0.9, 0.9, 0.9], 'FontColor', [0.3, 0.3, 0.3]);
    resetBtn.Layout.Row = 2;
    resetBtn.Layout.Column = 1;
    resetBtn.ButtonPushedFcn = @(src, event) resetApp();
    
    exportBtn = uibutton(controlGrid, 'push', 'Text', '导出结果', ...
                        'Enable', 'off', ...
                        'BackgroundColor', [0.2, 0.5, 0.8], 'FontColor', 'white');
    exportBtn.Layout.Row = 2;
    exportBtn.Layout.Column = 2;
    exportBtn.ButtonPushedFcn = @(src, event) exportResults();
    
    % 添加生成Word报告按钮
    generateReportBtn = uibutton(controlGrid, 'push', 'Text', '生成Word报告', ...
                                'Enable', 'off', ...
                                'BackgroundColor', [0.8, 0.2, 0.5], 'FontColor', 'white');
    generateReportBtn.Layout.Row = 3;
    generateReportBtn.Layout.Column = [1, 2];  % 跨两列
    generateReportBtn.ButtonPushedFcn = @(src, event) generateWordReport();
    
    %% 进度显示区域 - 响应式面板
    progressPanel = uipanel(leftGrid, 'Title', '进度状态', ...
                           'BorderType', 'line', 'HighlightColor', [1.0, 0.7, 0.3], ...
                           'BackgroundColor', [1.0, 0.99, 0.96]);
    progressPanel.Layout.Row = 4;
    progressPanel.Layout.Column = 1;
    
    % 进度区域内部网格布局
    progressGrid = uigridlayout(progressPanel, [3, 1]);
    progressGrid.RowHeight = {20, 30, '1x'};  % 状态标签，进度条，消息区域
    progressGrid.Padding = [8, 8, 8, 8];
    progressGrid.RowSpacing = 5;
    
    progressLabel = uilabel(progressGrid, 'Text', '就绪', 'FontWeight', 'bold', ...
                           'FontColor', [0.3, 0.3, 0.3]);
    progressLabel.Layout.Row = 1;
    progressLabel.Layout.Column = 1;
    
    progressGauge = uigauge(progressGrid, 'linear', 'Limits', [0, 100], ...
                           'ScaleColors', [0.2, 0.7, 0.2]);
    progressGauge.Layout.Row = 2;
    progressGauge.Layout.Column = 1;
    
    statusArea = uitextarea(progressGrid, ...
                           'Editable', 'off', 'Value', {'欢迎使用成绩分析系统！'}, ...
                           'BackgroundColor', [1.0, 1.0, 1.0]);
    statusArea.Layout.Row = 3;
    statusArea.Layout.Column = 1;
    
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
        
        % 初始化权重表格
        setupWeightTable();
        
        % 如果权重文件存在，自动加载数据
        if ~isempty(weightFileField.Value) && exist(weightFileField.Value, 'file')
            autoLoadWeightDataFromFile();
        end
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
            % 自动加载权重数据到表格
            autoLoadWeightDataFromFile();
        end
    end
    
    function onWeightFileChanged()
        % 权重文件路径改变时的回调
        if ~isempty(weightFileField.Value) && exist(weightFileField.Value, 'file')
            autoLoadWeightDataFromFile();
        elseif ~isempty(weightFileField.Value)
            addStatusMessage('⚠ 指定的权重文件不存在');
        end
    end
    
    function browseOutputDir()
        folder = uigetdir(pwd, '选择输出目录');
        if folder ~= 0
            outputDirField.Value = folder;
        end
    end
    
    function runAnalysis()
        % 禁用按钮
        runAnalysisBtn.Enable = 'off';
        runAnalysisBtn.Text = '分析中...';
        
        try
            % 验证输入
            if ~validateInputs()
                addStatusMessage('✗ 输入验证失败，请检查文件路径');
                return;
            end
            
            % 检查权重数据来源
            if weightModeGroup.SelectedObject == weightFromTableBtn
                % 手动编辑模式 - 使用表格数据
                addStatusMessage('使用手动编辑的权重数据...');
                
                % 先保存表格权重到临时文件
                tempWeightFile = fullfile(outputDirField.Value, 'temp_weights.xlsx');
                saveWeightToTempFile(tempWeightFile);
                
                % 创建分析器对象
                appData.analyzer = GradeAnalysisClass(scoreFileField.Value, ...
                                                     tempWeightFile, ...
                                                     outputDirField.Value);
            else
                % 文件读取模式
                addStatusMessage('使用权重文件数据...');
                appData.analyzer = GradeAnalysisClass(scoreFileField.Value, ...
                                                     weightFileField.Value, ...
                                                     outputDirField.Value);
            end
            
            % 设置进度回调
            appData.analyzer.setProgressCallback(@updateProgress);
            
            % 清空状态并显示开始消息
            statusArea.Value = {''};
            addStatusMessage('开始分析...');
            
            % 运行完整分析
            success = appData.analyzer.runCompleteAnalysis();
            
            if success
                appData.isAnalysisComplete = true;
                
                % 生成横向树状表格
                try
                    addStatusMessage('生成横向树状表格...');
                    appData.analyzer.generateHorizontalTreeTable();
                    addStatusMessage('✓ 横向树状表格生成完成');
                catch ME
                    addStatusMessage(['⚠ 横向树状表格生成失败: ' ME.message]);
                end
                
                % 生成目标达成度等级统计表格
                try
                    addStatusMessage('生成目标达成度等级统计表格...');
                    appData.analyzer.generateAchievementLevelTable();
                    addStatusMessage('✓ 目标达成度等级统计表格生成完成');
                catch ME
                    addStatusMessage(['⚠ 目标达成度等级统计表格生成失败: ' ME.message]);
                end
                
                displayResults();
                exportBtn.Enable = 'on';
                generateReportBtn.Enable = 'on';
                addStatusMessage('✓ 分析完成！所有结果已保存，包括新增的两个统计表格。');
                
                % 清理临时文件
                cleanupTempFiles();
            else
                addStatusMessage('✗ 分析失败！');
            end
            
        catch ME
            addStatusMessage(['✗ 错误: ' ME.message]);
            appData.isAnalysisComplete = false;
            exportBtn.Enable = 'off';
            generateReportBtn.Enable = 'off';
            cleanupTempFiles();
        end
        
        % 始终恢复按钮状态（移到try-catch外部）
        runAnalysisBtn.Enable = 'on';
        runAnalysisBtn.Text = '开始分析';
    end
    
    function resetApp()
        % 重置所有状态
        progressGauge.Value = 0;
        progressLabel.Text = '就绪';
        statusArea.Value = {''};
        appData.isAnalysisComplete = false;
        
        % 重置按钮状态
        runAnalysisBtn.Enable = 'on';
        runAnalysisBtn.Text = '开始分析';
        exportBtn.Enable = 'off';
        generateReportBtn.Enable = 'off';
        
        % 重置权重编辑状态
        weightModeGroup.SelectedObject = weightFromFileBtn;
        switchWeightMode();
        
        % 清空结果显示
        clearResults();
        addStatusMessage('✓ 界面已重置，可以开始新的分析');
    end
    
    function saveWeightToTempFile(tempFile)
        % 保存权重表格数据到临时文件
        try
            tableData = weightTable.Data;
            if isempty(tableData)
                error('权重表格为空');
            end
            
            % 确保输出目录存在
            if ~exist(outputDirField.Value, 'dir')
                mkdir(outputDirField.Value);
            end
            
            % 创建标准格式的权重表格（带表头）
            headers = {'项目', '目标1', '目标2', '目标3', '合计'};
            
            % 准备数据矩阵
            projectNames = cell(5, 1);
            projectNames{1} = headers{1};
            for i = 1:4
                projectNames{i+1} = tableData{i, 1};
            end
            
            col2 = [headers{2}; num2cell(cell2mat(tableData(:, 2)))];
            col3 = [headers{3}; num2cell(cell2mat(tableData(:, 3)))];
            col4 = [headers{4}; num2cell(cell2mat(tableData(:, 4)))];
            col5 = [headers{5}; num2cell(cell2mat(tableData(:, 5)))];
            
            % 转换为table并保存
            T = table(string(projectNames), cell2mat(col2), ...
                     cell2mat(col3), cell2mat(col4), ...
                     cell2mat(col5), ...
                     'VariableNames', headers);
            
            writetable(T, tempFile);
            addStatusMessage(['✓ 权重数据已保存到临时文件: ' tempFile]);
            
        catch ME
            error(['保存临时权重文件失败: ' ME.message]);
        end
    end
    
    function cleanupTempFiles()
        % 清理临时文件
        try
            tempFile = fullfile(outputDirField.Value, 'temp_weights.xlsx');
            if exist(tempFile, 'file')
                delete(tempFile);
                addStatusMessage('✓ 临时文件已清理');
            end
        catch ME
            addStatusMessage(['⚠ 清理临时文件时出错: ' ME.message]);
        end
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
    
    function generateWordReport()
        if ~appData.isAnalysisComplete
            uialert(fig, '请先完成分析', '提示');
            return;
        end
        
        % 禁用按钮
        generateReportBtn.Enable = 'off';
        generateReportBtn.Text = '生成中...';
        
        try
            addStatusMessage('开始生成Word报告...');
            
            % 创建LaTeX报告生成器，指定模板文件
            templateFile = fullfile('refer_word', '附件4.课程目标达成情况分析报告模板.tex');
            reportGenerator = LaTeXReportGenerator(appData.analyzer.getOutputDir(), templateFile);
            
            % 设置进度回调
            reportGenerator.setProgressCallback(@updateProgress);
            
            % 生成Word报告
            success = reportGenerator.generateWordReport(appData.analyzer);
            
            if success
                addStatusMessage('✓ Word报告生成完成！');
                uialert(fig, 'Word报告已成功生成到输出目录', '生成成功', 'Icon', 'success');
            else
                addStatusMessage('✗ Word报告生成失败');
                uialert(fig, 'Word报告生成失败，请查看状态信息', '生成失败');
            end
            
        catch ME
            addStatusMessage(['✗ 生成Word报告时出错: ' ME.message]);
            uialert(fig, ['生成失败: ' ME.message], '错误');
        end
        
        % 恢复按钮状态
        generateReportBtn.Enable = 'on';
        generateReportBtn.Text = '生成Word报告';
    end
    
    function valid = validateInputs()
        valid = true;
        
        if isempty(scoreFileField.Value) || ~exist(scoreFileField.Value, 'file')
            uialert(fig, '请选择有效的成绩文件', '输入错误');
            valid = false;
            return;
        end
        
        % 检查权重数据来源
        if weightModeGroup.SelectedObject == weightFromFileBtn
            % 文件读取模式，需要验证权重文件
            if isempty(weightFileField.Value) || ~exist(weightFileField.Value, 'file')
                uialert(fig, '请选择有效的权重文件', '输入错误');
                valid = false;
                return;
            end
        else
            % 手动编辑模式，验证权重表格数据
            if isempty(weightTable.Data)
                uialert(fig, '权重表格为空，请输入权重数据', '输入错误');
                valid = false;
                return;
            end
            
            % 验证权重数据的合理性
            try
                tableData = weightTable.Data;
                total = tableData{4, 5}; % 合计行的总权重
                if abs(total - 1.0) > 0.01 && abs(total - 100) > 1
                    uialert(fig, '权重总和应该等于1或100，请检查权重数据', '输入错误');
                    valid = false;
                    return;
                end
            catch
                uialert(fig, '权重表格数据格式不正确，请检查', '输入错误');
                valid = false;
                return;
            end
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

    %% 权重编辑相关函数
    
    function setupWeightTable()
        % 初始化权重表格
        defaultData = {
            '考勤',   0.05, 0.05, 0.00, 0.10;
            '平时作业', 0.10, 0.15, 0.05, 0.30;
            '期末考试', 0.25, 0.20, 0.15, 0.60;
            '合计',   0.40, 0.40, 0.20, 1.00
        };
        
        weightTable.Data = defaultData;
        weightTable.ColumnName = {'项目', '目标1', '目标2', '目标3', '合计'};
        weightTable.ColumnWidth = {60, 45, 45, 45, 45};
        weightTable.CellEditCallback = @validateWeightTable;
        
        % 设置行颜色
        weightTable.BackgroundColor = [1 1 1; 0.95 0.95 1];
    end
    
    function autoLoadWeightDataFromFile()
        % 自动从权重文件加载数据到表格
        try
            if isempty(weightFileField.Value) || ~exist(weightFileField.Value, 'file')
                addStatusMessage('⚠ 权重文件不存在，使用默认权重数据');
                return;
            end
            
            % 读取权重文件 - 使用VariableNamingRule为preserve保持原始列名
            weightData = readtable(weightFileField.Value, 'VariableNamingRule', 'preserve');
            [m, n] = size(weightData);
            
            if n < 5 || m < 4
                addStatusMessage('⚠ 权重文件格式不正确，使用默认权重数据');
                return;
            end
            
            % 直接读取数据行（从第1行开始，因为readtable已经处理了标题）
            tableData = cell(4, 5);
            for i = 1:min(4, m)
                % 第一列是项目名称
                if iscell(weightData{i, 1})
                    tableData{i, 1} = char(weightData{i, 1});
                elseif isstring(weightData{i, 1})
                    tableData{i, 1} = char(weightData{i, 1});
                else
                    tableData{i, 1} = char(string(weightData{i, 1}));
                end
                
                % 后面是数值数据
                for j = 2:5
                    if j <= n
                        tableData{i, j} = weightData{i, j};
                    else
                        tableData{i, j} = 0;
                    end
                end
            end
            
            % 强制重新计算合计行
            tableData{4, 1} = '合计';
            for j = 2:4
                total = 0;
                for i = 1:3
                    if isnumeric(tableData{i, j})
                        total = total + tableData{i, j};
                    end
                end
                tableData{4, j} = total;
            end
            tableData{4, 5} = sum(cell2mat(tableData(4, 2:4)));
            
            % 更新表格显示
            weightTable.Data = tableData;
            addStatusMessage(['✓ 已自动加载权重文件: ' char(extractAfter(weightFileField.Value, max(strfind(weightFileField.Value, filesep))))]);
            
        catch ME
            addStatusMessage(['⚠ 自动加载权重文件失败: ' ME.message '，使用默认权重数据']);
            fprintf('详细错误信息: %s\n', ME.getReport()); % 调试用
        end
    end
    
    function switchWeightMode()
        % 切换权重数据模式
        if weightModeGroup.SelectedObject == weightFromTableBtn
            % 手动编辑模式
            weightTable.Enable = 'on';
            weightTable.ColumnEditable = [false, true, true, true, false];  % 可编辑
            weightFileField.Enable = 'off';
            weightFileBrowseBtn.Enable = 'off';
            loadWeightBtn.Enable = 'off';
            addStatusMessage('✓ 已切换到手动编辑权重模式');
        else
            % 文件读取模式 - 表格显示但不可编辑
            weightTable.Enable = 'on';  % 显示数据
            weightTable.ColumnEditable = [false, false, false, false, false];  % 不可编辑
            weightFileField.Enable = 'on';
            weightFileBrowseBtn.Enable = 'on';
            loadWeightBtn.Enable = 'on';
            addStatusMessage('✓ 已切换到文件读取权重模式');
            
            % 切换到文件模式时，如果有权重文件则自动加载
            if ~isempty(weightFileField.Value) && exist(weightFileField.Value, 'file')
                autoLoadWeightDataFromFile();
            end
        end
    end
    
    function loadWeightData()
        % 从文件加载权重数据到表格（手动点击"加载"按钮时调用）
        try
            if isempty(weightFileField.Value) || ~exist(weightFileField.Value, 'file')
                uialert(fig, '请先选择有效的权重文件', '错误');
                return;
            end
            
            % 调用自动加载函数，保持逻辑一致
            autoLoadWeightDataFromFile();
            
            % 显示成功消息
            uialert(fig, '权重数据加载成功！', '成功', 'Icon', 'success');
            
        catch ME
            addStatusMessage(['✗ 手动加载权重文件失败: ' ME.message]);
            uialert(fig, ['加载失败: ' ME.message], '错误');
        end
    end
    
    function saveWeightData()
        % 保存权重数据到文件
        try
            tableData = weightTable.Data;
            if isempty(tableData)
                uialert(fig, '权重表格为空，无法保存', '错误');
                return;
            end
            
            % 创建保存的权重表格
            headers = {'项目', '目标1', '目标2', '目标3', '合计'};
            weightSaveData = [headers; tableData];
            
            % 选择保存路径
            [file, path] = uiputfile({'*.xlsx', 'Excel文件'}, '保存权重文件', ...
                                    fullfile(pwd, 'data', '自定义权重.xlsx'));
            if file == 0
                return;
            end
            
            saveFile = fullfile(path, file);
            
            % 转换为table并保存
            T = table(string(tableData(:,1)), cell2mat(tableData(:,2)), ...
                     cell2mat(tableData(:,3)), cell2mat(tableData(:,4)), ...
                     cell2mat(tableData(:,5)), ...
                     'VariableNames', headers);
            
            writetable(T, saveFile);
            
            % 更新权重文件路径
            weightFileField.Value = saveFile;
            
            addStatusMessage(['✓ 权重数据已保存至: ' saveFile]);
            uialert(fig, '权重数据保存成功！', '成功', 'Icon', 'success');
            
        catch ME
            addStatusMessage(['✗ 保存权重文件失败: ' ME.message]);
            uialert(fig, ['保存失败: ' ME.message], '错误');
        end
    end
    
    function validateWeightTable(src, event)
        % 验证权重表格数据
        try
            if event.Indices(1) < 4  % 前三行项目权重
                % 自动更新合计行
                tableData = src.Data;
                for j = 2:4  % 目标1-3列
                    total = 0;
                    for i = 1:3  % 前三行
                        if ~isempty(tableData{i, j}) && isnumeric(tableData{i, j})
                            total = total + tableData{i, j};
                        end
                    end
                    tableData{4, j} = total;
                end
                
                % 更新最后一列合计
                for i = 1:4
                    rowTotal = 0;
                    for j = 2:4
                        if ~isempty(tableData{i, j}) && isnumeric(tableData{i, j})
                            rowTotal = rowTotal + tableData{i, j};
                        end
                    end
                    tableData{i, 5} = rowTotal;
                end
                
                src.Data = tableData;
                
                % 验证权重合理性
                total = tableData{4, 5};
                if abs(total - 1.0) > 0.01 && abs(total - 100) > 1
                    addStatusMessage('⚠ 权重总和不等于1或100，请检查数据');
                else
                    addStatusMessage('✓ 权重数据已更新');
                end
            end
        catch ME
            addStatusMessage(['✗ 权重表格验证失败: ' ME.message]);
        end
    end
    
    function weightData = getWeightFromTable()
        % 从表格获取权重数据，返回与文件格式兼容的table
        try
            tableData = weightTable.Data;
            if isempty(tableData)
                error('权重表格为空');
            end
            
            % 创建与原始权重文件格式兼容的table
            headers = {'项目', '目标1', '目标2', '目标3', '合计'};
            weightData = table(string(tableData(:,1)), cell2mat(tableData(:,2)), ...
                              cell2mat(tableData(:,3)), cell2mat(tableData(:,4)), ...
                              cell2mat(tableData(:,5)), ...
                              'VariableNames', headers);
        catch ME
            error(['获取权重数据失败: ' ME.message]);
        end
    end

end 