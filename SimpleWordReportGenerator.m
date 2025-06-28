function SimpleWordReportGenerator(autoOpen)
    % SimpleWordReportGenerator - 简化的Word报告生成器
    % 
    % 功能：
    %   - 使用COM接口操作Word
    %   - 读取已生成的Excel表格数据
    %   - 替换模板中的占位符
    %   - 在{定量评价表格}位置插入"目标评价横向树状表.xlsx"
    %   - 在{定性评价表格}位置插入"目标达成度等级统计表.xlsx"
    %
    % 参数：
    %   autoOpen - (可选) true表示自动打开生成的文件，false或不提供则不打开
    %
    % 使用方法：
    %   SimpleWordReportGenerator()        % 使用默认路径，不自动打开
    %   SimpleWordReportGenerator(true)    % 使用默认路径，自动打开文件
    
    if nargin < 1
        autoOpen = false;
    end
    
    fprintf('=== 开始生成Word分析报告 ===\n');
    
    try
        % 步骤1：检查Excel文件是否存在
        fprintf('步骤1: 检查Excel数据文件...\n');
        outputDir = 'output';
        requiredFiles = {
            '学生成绩排名.xlsx',
            '成绩等级分布.xlsx',
            '目标达成度分析.xlsx',
            '目标评价横向树状表.xlsx',
            '目标达成度等级统计表.xlsx'
        };
        
        missingFiles = {};
        for i = 1:length(requiredFiles)
            filePath = fullfile(outputDir, requiredFiles{i});
            if ~exist(filePath, 'file')
                missingFiles{end+1} = requiredFiles{i};
            end
        end
        
        if ~isempty(missingFiles)
            error('缺少必要的Excel文件：%s\n请先运行主程序生成数据文件', strjoin(missingFiles, ', '));
        end
        
        fprintf('  ✓ 所有Excel数据文件存在\n');
        
        % 步骤2：设置文件路径
        fprintf('步骤2: 设置文件路径...\n');
        templatePath = fullfile('refer_word', '附件4.课程目标达成情况分析报告模板.docx');
        
        % 确保output文件夹存在
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
            fprintf('  创建输出目录: %s\n', outputDir);
        end
        
        % 生成输出文件路径
        outputFileName = sprintf('课程分析报告_%s.docx', datestr(now, 'yyyymmdd_HHMMSS'));
        outputPath = fullfile(outputDir, outputFileName);
        
        % 检查模板文件
        if ~exist(templatePath, 'file')
            error('模板文件不存在: %s', templatePath);
        end
        
        fprintf('模板文件: %s\n', templatePath);
        fprintf('输出文件: %s\n', outputPath);
        
        % 步骤3：生成Word报告
        fprintf('步骤3: 生成Word报告...\n');
        success = generateReport(outputDir, templatePath, outputPath);
        
        % 步骤4：结果反馈
        if success
            fprintf('✓ Word报告生成成功\n');
            fprintf('✓ 保存位置: %s\n', outputPath);
            
            % 显示文件信息
            fileInfo = dir(outputPath);
            if ~isempty(fileInfo)
                fprintf('✓ 文件大小: %.2f KB\n', fileInfo.bytes / 1024);
            end
            
            % 根据参数决定是否自动打开文件
            fprintf('✓ 报告生成完成，文件位置: %s\n', outputPath);
            
            if autoOpen
                try
                    if ispc
                        system(['start "" "' outputPath '"']);
                    elseif ismac
                        system(['open "' outputPath '"']);
                    else
                        system(['xdg-open "' outputPath '"']);
                    end
                    fprintf('✓ 正在自动打开报告文件...\n');
                catch
                    fprintf('✗ 无法自动打开文件，请手动打开: %s\n', outputPath);
                end
            end
        else
            fprintf('✗ Word报告生成失败\n');
            fprintf('请检查output文件夹的写入权限\n');
        end
        
    catch ME
        fprintf('✗ 错误: %s\n', ME.message);
        fprintf('详细信息:\n%s\n', ME.getReport());
    end
end

function success = generateReport(outputDir, templatePath, outputPath)
    % 生成Word报告的核心函数
    
    wordApp = [];
    doc = [];
    success = false;
    
    try
        % 1. 启动Word应用程序
        fprintf('  启动Word应用程序...\n');
        wordApp = actxserver('Word.Application');
        wordApp.Visible = false;
        wordApp.DisplayAlerts = false;
        
        % 2. 打开模板文件
        fprintf('  打开模板文件...\n');
        absolutePath = getAbsolutePath(templatePath);
        doc = wordApp.Documents.Open(absolutePath);
        
        % 3. 准备替换数据
        fprintf('  准备数据...\n');
        replaceData = prepareReplaceData(outputDir);
        
        % 4. 执行占位符替换
        fprintf('  替换占位符...\n');
        replaceAllPlaceholders(doc, replaceData);
        
        % 5. 插入Excel表格到占位符位置
        fprintf('  插入Excel表格...\n');
        insertExcelTables(doc, outputDir);
        
        % 6. 保存文档到output文件夹
        fprintf('  保存文档到output文件夹...\n');
        
        % 获取绝对路径并保存
        absoluteOutputPath = getAbsolutePath(outputPath);
        fprintf('  保存路径: %s\n', absoluteOutputPath);
        
        % 使用SaveAs2方法保存文档
        doc.SaveAs2(absoluteOutputPath, 16);  % 16 = wdFormatDocumentDefault
        
        % 验证文件是否成功保存
        if exist(absoluteOutputPath, 'file')
            fprintf('  ✓ 文件保存成功\n');
            success = true;
        else
            fprintf('  ✗ 文件保存失败\n');
            success = false;
        end
        
    catch ME
        fprintf('  生成报告时出错: %s\n', ME.message);
        success = false;
    end
    
    % 清理资源
    try
        if ~isempty(doc)
            doc.Close(0);  % 不保存更改
        end
        if ~isempty(wordApp)
            wordApp.Quit();
        end
    catch
        % 忽略清理错误
    end
end

function data = prepareReplaceData(outputDir)
    % 准备要替换的数据 - 从Excel文件读取
    
    fprintf('  从Excel文件读取数据...\n');
    
    try
        % 读取学生成绩排名表
        fprintf('    读取学生成绩排名.xlsx...\n');
        rankingFile = fullfile(outputDir, '学生成绩排名.xlsx');
        rankingData = readtable(rankingFile, 'ReadVariableNames', true);
        
        % 读取成绩等级分布表
        fprintf('    读取成绩等级分布.xlsx...\n');
        gradeFile = fullfile(outputDir, '成绩等级分布.xlsx');
        gradeData = readtable(gradeFile, 'ReadVariableNames', true);
        
        % 读取目标达成度分析表
        fprintf('    读取目标达成度分析.xlsx...\n');
        targetFile = fullfile(outputDir, '目标达成度分析.xlsx');
        targetData = readtable(targetFile, 'ReadVariableNames', true);
        
        % 基本信息（固定值，可以根据需要修改）
        data.COURSE_NAME = '数学建模方法与分析';
        data.COURSE_CODE = 'MATH2021';
        data.TEACHER = '张教师';
        data.START_TIME = '2023年9月';
        data.CLASS = '2021级';
        data.EVALUATOR = '系统管理员';
        
        % 从学生成绩排名表获取统计数据
        if ~isempty(rankingData) && height(rankingData) > 0
            try
                totalStudents = height(rankingData);
                
                % 查找包含数值的列（通常是总分列）
                scores = [];
                for col = 1:width(rankingData)
                    colData = rankingData{:, col};
                    if isnumeric(colData) && ~all(isnan(colData))
                        scores = colData;
                        break;
                    end
                end
                
                % 如果找到了数值列，计算统计数据
                if ~isempty(scores)
                    % 过滤掉NaN值
                    validScores = scores(~isnan(scores));
                    if ~isempty(validScores)
                        data.TOTAL_STUDENTS = sprintf('%d', totalStudents);
                        data.STUDENT_COUNT = sprintf('%d', totalStudents);
                        data.AVG_SCORE = sprintf('%.2f', mean(validScores));
                        data.MAX_SCORE = sprintf('%.2f', max(validScores));
                        data.MIN_SCORE = sprintf('%.2f', min(validScores));
                        data.STD_SCORE = sprintf('%.2f', std(validScores));
                    else
                        % 没有有效数据，使用默认值
                        data.TOTAL_STUDENTS = sprintf('%d', totalStudents);
                        data.STUDENT_COUNT = sprintf('%d', totalStudents);
                        data.AVG_SCORE = '0.00';
                        data.MAX_SCORE = '0.00';
                        data.MIN_SCORE = '0.00';
                        data.STD_SCORE = '0.00';
                    end
                else
                    % 没有找到数值列，只设置学生数量
                    data.TOTAL_STUDENTS = sprintf('%d', totalStudents);
                    data.STUDENT_COUNT = sprintf('%d', totalStudents);
                    data.AVG_SCORE = '0.00';
                    data.MAX_SCORE = '0.00';
                    data.MIN_SCORE = '0.00';
                    data.STD_SCORE = '0.00';
                end
            catch ME
                fprintf('    警告: 处理成绩数据时出错: %s\n', ME.message);
                % 使用默认值
                data.TOTAL_STUDENTS = '0';
                data.STUDENT_COUNT = '0';
                data.AVG_SCORE = '0.00';
                data.MAX_SCORE = '0.00';
                data.MIN_SCORE = '0.00';
                data.STD_SCORE = '0.00';
            end
        else
            % 默认值
            data.TOTAL_STUDENTS = '0';
            data.STUDENT_COUNT = '0';
            data.AVG_SCORE = '0.00';
            data.MAX_SCORE = '0.00';
            data.MIN_SCORE = '0.00';
            data.STD_SCORE = '0.00';
        end
        
        % 从目标达成度分析表获取目标达成度数据
        if ~isempty(targetData) && height(targetData) >= 3
            try
                % 查找包含数值的列（目标达成度列）
                achievements = [];
                for col = 1:width(targetData)
                    colData = targetData{:, col};
                    if isnumeric(colData) && length(colData) >= 3
                        achievements = colData;
                        break;
                    end
                end
                
                if ~isempty(achievements) && length(achievements) >= 3
                    % 确保数据是数值类型
                    validAchievements = achievements(1:3);
                    validAchievements(isnan(validAchievements)) = 0; % 将NaN替换为0
                    
                    data.TARGET1_ACHIEVEMENT = sprintf('%.2f', validAchievements(1));
                    data.TARGET2_ACHIEVEMENT = sprintf('%.2f', validAchievements(2));
                    data.TARGET3_ACHIEVEMENT = sprintf('%.2f', validAchievements(3));
                else
                    data.TARGET1_ACHIEVEMENT = '0.00';
                    data.TARGET2_ACHIEVEMENT = '0.00';
                    data.TARGET3_ACHIEVEMENT = '0.00';
                end
            catch ME
                fprintf('    警告: 处理目标达成度数据时出错: %s\n', ME.message);
                data.TARGET1_ACHIEVEMENT = '0.00';
                data.TARGET2_ACHIEVEMENT = '0.00';
                data.TARGET3_ACHIEVEMENT = '0.00';
            end
        else
            data.TARGET1_ACHIEVEMENT = '0.00';
            data.TARGET2_ACHIEVEMENT = '0.00';
            data.TARGET3_ACHIEVEMENT = '0.00';
        end
        
        % 从成绩等级分布表获取等级分布数据
        grades = {'A', 'B', 'C', 'D', 'E'};
        
        % 初始化所有等级为0
        for i = 1:length(grades)
            grade = grades{i};
            data.(['GRADE_' grade '_COUNT']) = '0';
            data.(['GRADE_' grade '_PERCENT']) = '0.0';
        end
        
        if ~isempty(gradeData) && height(gradeData) > 0
            try
                for i = 1:height(gradeData)
                    try
                        % 尝试读取等级名称（可能在第一列）
                        gradeValue = gradeData{i, 1};
                        
                        % 处理不同的数据类型
                        if iscell(gradeValue)
                            grade = char(gradeValue{1});
                        elseif ischar(gradeValue) || isstring(gradeValue)
                            grade = char(gradeValue);
                        else
                            continue; % 跳过无法识别的等级
                        end
                        
                        % 查找人数和百分比列
                        count = 0;
                        percent = 0;
                        
                        % 尝试从后续列中读取数值
                        for col = 2:width(gradeData)
                            colData = gradeData{i, col};
                            if isnumeric(colData) && ~isnan(colData)
                                if count == 0
                                    count = colData;
                                else
                                    percent = colData;
                                    break;
                                end
                            end
                        end
                        
                        % 如果找到了匹配的等级，更新数据
                        if any(strcmp(grade, grades))
                            data.(['GRADE_' grade '_COUNT']) = sprintf('%d', round(count));
                            data.(['GRADE_' grade '_PERCENT']) = sprintf('%.1f', percent);
                        end
                        
                    catch
                        % 跳过无法处理的行
                        continue;
                    end
                end
            catch ME
                fprintf('    警告: 读取等级分布数据时出错: %s\n', ME.message);
            end
        end
        
        fprintf('  ✓ 数据读取完成\n');
        
    catch ME
        fprintf('  ✗ 读取Excel数据时出错: %s\n', ME.message);
        % 使用默认值
        data = getDefaultData();
    end
end

function data = getDefaultData()
    % 返回默认数据（当Excel文件读取失败时使用）
    
    data.COURSE_NAME = '数学建模方法与分析';
    data.COURSE_CODE = 'MATH2021';
    data.TEACHER = '张教师';
    data.START_TIME = '2023年9月';
    data.CLASS = '2021级';
    data.EVALUATOR = '系统管理员';
    
    data.TOTAL_STUDENTS = '0';
    data.STUDENT_COUNT = '0';
    data.AVG_SCORE = '0.00';
    data.MAX_SCORE = '0.00';
    data.MIN_SCORE = '0.00';
    data.STD_SCORE = '0.00';
    
    data.TARGET1_ACHIEVEMENT = '0.00';
    data.TARGET2_ACHIEVEMENT = '0.00';
    data.TARGET3_ACHIEVEMENT = '0.00';
    
    grades = {'A', 'B', 'C', 'D', 'E'};
    for i = 1:length(grades)
        grade = grades{i};
        data.(['GRADE_' grade '_COUNT']) = '0';
        data.(['GRADE_' grade '_PERCENT']) = '0.0';
    end
end

function replaceAllPlaceholders(doc, data)
    % 替换文档中的所有占位符
    
    fieldNames = fieldnames(data);
    
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        placeholder = ['{' fieldName '}'];
        value = data.(fieldName);
        
        try
            replaceText(doc, placeholder, value);
        catch ME
            fprintf('    替换 %s 时出错: %s\n', placeholder, ME.message);
        end
    end
end

function replaceText(doc, findText, replaceText)
    % 在文档中查找并替换文本
    
    try
        % 使用Word的查找替换功能 - 简化版本
        selection = doc.Application.Selection;
        
        % 移动到文档开头
        selection.HomeKey(6); % wdStory
        
        % 设置查找选项
        selection.Find.ClearFormatting();
        selection.Find.Replacement.ClearFormatting();
        selection.Find.Text = char(findText);
        selection.Find.Replacement.Text = char(replaceText);
        selection.Find.Forward = true;
        selection.Find.Wrap = 1;  % wdFindContinue
        selection.Find.Format = false;
        selection.Find.MatchCase = false;
        selection.Find.MatchWholeWord = false;
        selection.Find.MatchWildcards = false;
        
        % 执行替换所有
        selection.Find.Execute(selection.Find.Text, [], [], [], [], [], [], [], [], selection.Find.Replacement.Text, 2);
        
    catch ME
        % 如果上面的方法失败，尝试备用方法
        try
            % 方法2：使用Range对象
            range = doc.Content;
            
            % 简单的文本替换
            while range.Find.Execute(char(findText))
                range.Text = char(replaceText);
                range = doc.Content;
                range.Start = range.Start + length(char(replaceText));
            end
            
        catch ME2
            % 方法3：最简单的全文替换
            try
                content = doc.Content;
                currentText = content.Text;
                newText = strrep(currentText, char(findText), char(replaceText));
                content.Text = newText;
            catch ME3
                % 记录错误但不中断程序
                % fprintf('替换文本时出错: %s\n', ME3.message);
                rethrow(ME3);
            end
        end
    end
end

function insertExcelTables(doc, outputDir)
    % 插入Excel表格到Word文档的占位符位置
    
    try
        % 定义Excel表格文件路径
        quantitativeTableFile = fullfile(outputDir, '目标评价横向树状表.xlsx');
        qualitativeTableFile = fullfile(outputDir, '目标达成度等级统计表.xlsx');
        
        % 检查文件是否存在
        if ~exist(quantitativeTableFile, 'file')
            fprintf('    ✗ 目标评价横向树状表.xlsx 文件不存在\n');
            replaceText(doc, '{定量评价表格}', '[表格文件不存在]');
        else
            fprintf('    正在插入定量评价表格...\n');
            insertExcelTableAtPlaceholder(doc, '{定量评价表格}', quantitativeTableFile);
            fprintf('    ✓ 定量评价表格插入成功\n');
        end
        
        if ~exist(qualitativeTableFile, 'file')
            fprintf('    ✗ 目标达成度等级统计表.xlsx 文件不存在\n');
            replaceText(doc, '{定性评价表格}', '[表格文件不存在]');
        else
            fprintf('    正在插入定性评价表格...\n');
            insertExcelTableAtPlaceholder(doc, '{定性评价表格}', qualitativeTableFile);
            fprintf('    ✓ 定性评价表格插入成功\n');
        end
        
    catch ME
        fprintf('    ✗ 插入Excel表格时出错: %s\n', ME.message);
    end
end

function insertExcelTableAtPlaceholder(doc, placeholder, excelFilePath)
    % 在指定占位符位置插入Excel表格
    
    try
        % 查找占位符
        selection = doc.Application.Selection;
        selection.HomeKey(6); % 移动到文档开头
        
        % 设置查找选项
        selection.Find.ClearFormatting();
        selection.Find.Text = placeholder;
        selection.Find.Forward = true;
        selection.Find.Wrap = 1; % wdFindContinue
        
        if selection.Find.Execute()
            fprintf('      ✓ 找到占位符: %s\n', placeholder);
            
            % 删除占位符文本
            selection.Delete();
            
            % 获取绝对路径
            absoluteExcelPath = getAbsolutePath(excelFilePath);
            
            % 读取Excel数据并转换为HTML表格
            try
                % 读取Excel表格数据
                [~, ~, raw] = xlsread(absoluteExcelPath);
                
                if isempty(raw)
                    fprintf('      ✗ Excel文件为空或无法读取\n');
                    selection.TypeText('[Excel文件读取失败]');
                    return;
                end
                
                % 创建Word表格
                numRows = size(raw, 1);
                numCols = size(raw, 2);
                
                % 在当前位置插入表格
                tableRange = selection.Range;
                wordTable = doc.Tables.Add(tableRange, numRows, numCols);
                
                % 填充表格数据
                for row = 1:numRows
                    for col = 1:numCols
                        try
                            cellValue = raw{row, col};
                            if ischar(cellValue) || isstring(cellValue)
                                cellText = char(cellValue);
                            elseif isnumeric(cellValue) && ~isnan(cellValue)
                                cellText = sprintf('%.2f', cellValue);
                            else
                                cellText = '';
                            end
                            
                            wordTable.Cell(row, col).Range.Text = cellText;
                        catch
                            % 如果某个单元格有问题，跳过
                            continue;
                        end
                    end
                end
                
                % 设置表格样式
                try
                    % 设置边框
                    wordTable.Borders.Enable = true;
                    
                    % 设置字体和对齐
                    for row = 1:numRows
                        for col = 1:numCols
                            cellRange = wordTable.Cell(row, col).Range;
                            cellRange.Font.Name = '宋体';
                            cellRange.Font.Size = 10;
                            cellRange.ParagraphFormat.Alignment = 1; % 居中对齐
                            wordTable.Cell(row, col).VerticalAlignment = 1; % 垂直居中
                        end
                    end
                    
                    % 设置表头样式（第一行）
                    if numRows > 0
                        for col = 1:numCols
                            headerRange = wordTable.Cell(1, col).Range;
                            headerRange.Font.Bold = true;
                            headerRange.Shading.BackgroundPatternColor = 15132390; % 浅灰色
                        end
                    end
                    
                    fprintf('      ✓ 表格样式设置成功\n');
                    
                catch ME2
                    fprintf('      警告: 设置表格样式时出错: %s\n', ME2.message);
                end
                
                fprintf('      ✓ Excel表格插入成功 (%d行%d列)\n', numRows, numCols);
                
            catch ME2
                fprintf('      ✗ 处理Excel数据时出错: %s\n', ME2.message);
                selection.TypeText('[Excel表格处理失败]');
            end
            
        else
            fprintf('      ✗ 未找到占位符: %s\n', placeholder);
        end
        
    catch ME
        fprintf('      ✗ 插入Excel表格时出错: %s\n', ME.message);
    end
end

function absolutePath = getAbsolutePath(relativePath)
    % 获取绝对路径
    
    if isAbsolutePath(relativePath)
        absolutePath = relativePath;
    else
        absolutePath = fullfile(pwd, relativePath);
    end
    
    function isAbs = isAbsolutePath(path)
        if ispc
            isAbs = length(path) >= 3 && path(2) == ':';
        else
            isAbs = ~isempty(path) && path(1) == '/';
        end
    end
end 