function generate_course_report(courseInfo, quantitativeData, qualitativeData, templatePath, outputPath)
    % GENERATE_COURSE_REPORT 依据模板生成课程目标达成情况分析报告
    
    % 参数示例：
    % courseInfo = struct('课程名称','数学建模','课程代码','MA101',...
    %                    '课程类别','必修','课程学分',3,...
    %                    '授课教师','张老师','考核方式','考查',...
    %                    '开课时间','2025春','授课班级','2021级A班',...
    %                    '学生人数',65,'达成期望值',0.7,...
    %                    '评价人','李主任','评价时间','2025年6月');
    %
    % quantitativeData = {
    %     '平时', 0.3, 15, 13.2, 0.871;
    %     '实验', 0.3, 10, 8.9, 0.871;
    %     '期末考试', 0.4, 20, 17, 0.871};
    %
    % qualitativeData = {
    %     '完全达成', 33;
    %     '较好达成', 20;
    %     '基本达成', 8;
    %     '未达成', 4;
    %     '达成率', 0.815};
    
    % 启动 Word 应用
    try
        wordApp = actxserver('Word.Application');
    catch
        error('无法启动 Word，请确认是否安装了 Microsoft Office 并运行于 Windows 系统');
    end
    
    wordApp.Visible = false; % 不显示 Word
    documents = wordApp.Documents;
    doc = documents.Open(templatePath);
    
    % 替换主标题中的《XXXX》
    replaceText(doc, 'XXXX', courseInfo.课程名称);
    
    % 定义字段映射
    fieldsMap = struct(...
        '课程名称', '课程名称', ...
        '课程代码', '课程代码', ...
        '课程类别', '课程类别', ...
        '课程学分', '课程学分', ...
        '授课教师', '授课教师', ...
        '考核方式', '考核方式', ...
        '开课时间', '开课时间', ...
        '授课班级', '授课班级', ...
        '学生人数', '学生人数', ...
        '达成期望值', '达成期望值', ...
        '评价人', '评价人', ...
        '评价时间', '评价时间');
    
    % 替换基础信息字段
    for field = fieldnames(fieldsMap)'
        fieldName = fieldsMap.(field{1});
        replaceText(doc, ['<', field{1}, '>'], num2strOrString(courseInfo.(fieldName)));
    end
    
    % 插入定量评价表格
    insertQuantitativeTable(doc, quantitativeData);
    
    % 插入定性评价表格
    insertQualitativeTable(doc, qualitativeData);
    
    % 保存文档
    doc.SaveAs2(outputPath);
    
    % 关闭文档
    doc.Close(false);
    
    % 退出 Word 应用
    wordApp.Quit;
    
    % 清理 COM 对象
    clear doc wordApp;
    
    disp(['已生成课程达成情况分析报告至：', outputPath]);
    
    end
    
    %% 子函数：文本替换
    function replaceText(doc, oldText, newText)
    findObj = doc.Content.Find;
    findObj.Execute(oldText, false, false);
    while findObj.Found
        findObj.Parent.Text = newText;
        findObj.Execute(oldText, false, false);
    end
    end
    
    %% 子函数：插入定量评价表格
    function insertQuantitativeTable(doc, data)
    tables = doc.Tables;
    if tables.Count >= 2
        tableIndex = 2; % 假设定量评价在第2个表格
        tbl = tables.Item(tableIndex);
        
        for i = 1:size(data, 1)
            for j = 1:size(data, 2)
                cellContent = data{i, j};
                if isnumeric(cellContent)
                    cellContent = num2str(cellContent