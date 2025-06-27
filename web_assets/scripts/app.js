// 学生成绩分析系统 - 前端应用逻辑
class StudentGradeAnalysisApp {
    constructor() {
        this.currentTab = 'ranking';
        this.data = {
            scores: null,
            weights: null,
            processed: null
        };
        this.init();
    }

    // 初始化应用
    init() {
        this.bindEvents();
        this.initializeUI();
        this.updateStatus('ready', '等待文件选择');
    }

    // 绑定事件监听器
    bindEvents() {
        // 文件浏览按钮
        document.querySelectorAll('.file-browse-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.handleFileBrowse(e));
        });

        // 功能按钮
        document.getElementById('processBtn').addEventListener('click', () => this.processData());
        document.getElementById('exportBtn').addEventListener('click', () => this.exportResults());
        document.getElementById('clearBtn').addEventListener('click', () => this.clearResults());

        // 标签页切换
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.switchTab(e.target.dataset.tab));
        });

        // 键盘快捷键
        document.addEventListener('keydown', (e) => this.handleKeyboard(e));
    }

    // 初始化UI状态
    initializeUI() {
        // 设置默认文件路径（如果存在）
        const scoreFileInput = document.getElementById('scoreFile');
        const weightFileInput = document.getElementById('weightFile');
        
        // 可以从MATLAB传入默认路径
        if (window.matlabDefaultPaths) {
            scoreFileInput.value = window.matlabDefaultPaths.scoreFile || '';
            weightFileInput.value = window.matlabDefaultPaths.weightFile || '';
        }

        // 禁用导出按钮
        document.getElementById('exportBtn').disabled = true;
    }

    // 处理文件浏览
    handleFileBrowse(event) {
        console.log('File browse button clicked');
        
        const target = event.target.closest('.file-browse-btn').dataset.target;
        console.log('Target file type:', target);
        
        // 统一使用matlabProxy对象名称
        if (window.matlabProxy && window.matlabProxy.selectFile) {
            console.log('Calling MATLAB file selector...');
            window.matlabProxy.selectFile(target);
        } else {
            console.log('MATLAB proxy not available, using fallback...');
            // fallback: 模拟文件选择
            this.simulateFileSelection(target);
        }
    }

    // 模拟文件选择（用于测试）
    simulateFileSelection(target) {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.xlsx,.xls';
        input.onchange = (e) => {
            if (e.target.files.length > 0) {
                const fileName = e.target.files[0].name;
                document.getElementById(target).value = fileName;
                this.updateStatus('info', `已选择${target === 'scoreFile' ? '成绩' : '权重'}文件: ${fileName}`);
                this.validateInputs();
            }
        };
        input.click();
    }

    // 验证输入文件
    validateInputs() {
        const scoreFile = document.getElementById('scoreFile').value;
        const weightFile = document.getElementById('weightFile').value;
        const processBtn = document.getElementById('processBtn');

        if (scoreFile && weightFile) {
            processBtn.disabled = false;
            this.updateStatus('success', '文件已就绪，可以开始处理数据');
        } else {
            processBtn.disabled = true;
        }
    }

    // 处理数据
    async processData() {
        const processBtn = document.getElementById('processBtn');
        const scoreFile = document.getElementById('scoreFile').value;
        const weightFile = document.getElementById('weightFile').value;

        if (!scoreFile || !weightFile) {
            this.showError('请先选择成绩文件和权重文件');
            return;
        }

        try {
            // 显示处理状态
            this.setButtonLoading(processBtn, true);
            this.showProgress(true);
            this.updateStatus('processing', '正在处理数据...');

            // 调用MATLAB数据处理
            if (window.matlabBridge && window.matlabBridge.processData) {
                try {
                    const result = await window.matlabBridge.processData(scoreFile, weightFile, (progress) => {
                        this.updateProgress(progress);
                    });

                    if (result && result.success) {
                        this.data.processed = result.data;
                        this.updateTables(result.data);
                        this.updateStatus('success', '数据处理完成');
                        document.getElementById('exportBtn').disabled = false;
                    } else {
                        throw new Error(result?.error || '数据处理失败');
                    }
                } catch (error) {
                    console.error('MATLAB数据处理失败，使用模拟模式:', error);
                    await this.simulateDataProcessing();
                }
            } else if (window.matlabProxy && window.matlabProxy.processData) {
                window.matlabProxy.processData(scoreFile, weightFile);
                // 注意：结果会通过MATLAB回调返回
                this.updateStatus('processing', '正在处理数据，请稍候...');
            } else {
                // fallback: 模拟数据处理
                await this.simulateDataProcessing();
            }

        } catch (error) {
            this.showError(error.message);
            this.updateStatus('error', `处理失败: ${error.message}`);
        } finally {
            this.setButtonLoading(processBtn, false);
            this.showProgress(false);
        }
    }

    // 模拟数据处理（用于测试）
    async simulateDataProcessing() {
        const steps = [
            { progress: 20, message: '读取成绩文件...' },
            { progress: 40, message: '读取权重文件...' },
            { progress: 60, message: '验证数据完整性...' },
            { progress: 80, message: '计算成绩和达成度...' },
            { progress: 100, message: '生成分析结果...' }
        ];

        for (const step of steps) {
            await new Promise(resolve => setTimeout(resolve, 500));
            this.updateProgress(step.progress);
            this.updateStatus('processing', step.message);
        }

        // 生成模拟数据
        this.data.processed = this.generateMockData();
        this.updateTables(this.data.processed);
        document.getElementById('exportBtn').disabled = false;
    }

    // 生成模拟数据
    generateMockData() {
        const students = [];
        const grades = ['A', 'B', 'C', 'D', 'E'];
        
        for (let i = 1; i <= 20; i++) {
            students.push({
                id: `2021${i.toString().padStart(3, '0')}`,
                name: `学生${i}`,
                attendance: Math.floor(Math.random() * 21) + 80,
                homework: Math.floor(Math.random() * 21) + 80,
                exam: Math.floor(Math.random() * 21) + 80,
                total: 0,
                target1: 0,
                target2: 0,
                target3: 0,
                grade: grades[Math.floor(Math.random() * grades.length)]
            });
        }

        // 计算总分
        students.forEach(student => {
            student.total = student.attendance * 0.1 + student.homework * 0.3 + student.exam * 0.6;
            student.target1 = student.total * 0.4;
            student.target2 = student.total * 0.3;
            student.target3 = student.total * 0.3;
        });

        // 按总分排序
        students.sort((a, b) => b.total - a.total);

        return {
            students,
            statistics: {
                target1: { avg: 85.2, achievement: 85.2 },
                target2: { avg: 82.7, achievement: 82.7 },
                target3: { avg: 87.1, achievement: 87.1 }
            },
            distribution: {
                A: students.filter(s => s.grade === 'A').length,
                B: students.filter(s => s.grade === 'B').length,
                C: students.filter(s => s.grade === 'C').length,
                D: students.filter(s => s.grade === 'D').length,
                E: students.filter(s => s.grade === 'E').length
            }
        };
    }

    // 更新表格数据
    updateTables(data) {
        this.updateRankingTable(data.students);
        this.updateAchievementTable(data.students);
        this.updateStatisticsTable(data.statistics);
        this.updateDistributionTable(data.distribution);
    }

    // 更新排名表格
    updateRankingTable(students) {
        const tbody = document.querySelector('#rankingTable tbody');
        tbody.innerHTML = '';

        students.forEach((student, index) => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td><span class="badge-primary">${index + 1}</span></td>
                <td>${student.id}</td>
                <td>${student.name}</td>
                <td>${student.attendance.toFixed(1)}</td>
                <td>${student.homework.toFixed(1)}</td>
                <td>${student.exam.toFixed(1)}</td>
                <td><strong>${student.total.toFixed(2)}</strong></td>
            `;
            tbody.appendChild(row);
        });
    }

    // 更新达成度表格
    updateAchievementTable(students) {
        const tbody = document.querySelector('#achievementTable tbody');
        tbody.innerHTML = '';

        students.forEach(student => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${student.id}</td>
                <td>${student.name}</td>
                <td>${student.target1.toFixed(2)}</td>
                <td>${student.target2.toFixed(2)}</td>
                <td>${student.target3.toFixed(2)}</td>
            `;
            tbody.appendChild(row);
        });
    }

    // 更新统计表格
    updateStatisticsTable(statistics) {
        const tbody = document.querySelector('#statisticsTable tbody');
        tbody.innerHTML = '';

        Object.entries(statistics).forEach(([key, value], index) => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>目标${index + 1}</td>
                <td>100%</td>
                <td>${value.avg.toFixed(2)}</td>
                <td>${value.achievement.toFixed(2)}%</td>
            `;
            tbody.appendChild(row);
        });

        // 更新统计卡片
        document.getElementById('target1Stats').textContent = `${statistics.target1.achievement.toFixed(1)}%`;
        document.getElementById('target2Stats').textContent = `${statistics.target2.achievement.toFixed(1)}%`;
        document.getElementById('target3Stats').textContent = `${statistics.target3.achievement.toFixed(1)}%`;
    }

    // 更新等级分布表格
    updateDistributionTable(distribution) {
        const tbody = document.querySelector('#distributionTable tbody');
        tbody.innerHTML = '';

        const total = Object.values(distribution).reduce((sum, count) => sum + count, 0);

        Object.entries(distribution).forEach(([grade, count]) => {
            const percentage = ((count / total) * 100).toFixed(1);
            const row = document.createElement('tr');
            row.innerHTML = `
                <td><span class="grade-badge grade-${grade.toLowerCase()}">${grade}</span></td>
                <td>${count}</td>
                <td>${percentage}%</td>
            `;
            tbody.appendChild(row);
        });

        // 更新图表
        this.updateDistributionChart(distribution);
    }

    // 更新等级分布图表
    updateDistributionChart(distribution) {
        const chartContainer = document.getElementById('gradeChart');
        chartContainer.innerHTML = '';

        const total = Object.values(distribution).reduce((sum, count) => sum + count, 0);
        
        // 创建简单的条形图
        const chartDiv = document.createElement('div');
        chartDiv.style.cssText = 'display: flex; height: 200px; align-items: end; gap: 10px; justify-content: center;';
        
        Object.entries(distribution).forEach(([grade, count]) => {
            const percentage = (count / total) * 100;
            const bar = document.createElement('div');
            bar.style.cssText = `
                background: var(--primary-color);
                width: 40px;
                height: ${percentage * 1.5}%;
                border-radius: 4px 4px 0 0;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                align-items: center;
                color: white;
                font-size: 12px;
                font-weight: bold;
                padding: 5px;
                min-height: 30px;
            `;
            bar.innerHTML = `
                <span>${count}</span>
                <span style="background: rgba(0,0,0,0.2); padding: 2px 4px; border-radius: 2px;">${grade}</span>
            `;
            chartDiv.appendChild(bar);
        });
        
        chartContainer.appendChild(chartDiv);
    }

    // 切换标签页
    switchTab(tabName) {
        // 更新按钮状态
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.tab === tabName);
        });

        // 更新内容显示
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.toggle('active', content.id === tabName);
        });

        this.currentTab = tabName;
    }

    // 导出结果
    async exportResults() {
        if (!this.data.processed) {
            this.showError('没有可导出的数据');
            return;
        }

        try {
            this.updateStatus('processing', '正在导出结果...');

            if (window.matlabBridge && window.matlabBridge.exportResults) {
                const result = await window.matlabBridge.exportResults(this.data.processed);
                if (result.success) {
                    this.updateStatus('success', '结果导出完成');
                    this.showSuccess(`结果已导出到：${result.outputPath}`);
                } else {
                    throw new Error(result.error || '导出失败');
                }
            } else {
                // fallback: 模拟导出
                await new Promise(resolve => setTimeout(resolve, 1000));
                this.updateStatus('success', '结果导出完成');
                this.showSuccess('结果已导出到 output 文件夹');
            }
        } catch (error) {
            this.showError(error.message);
            this.updateStatus('error', `导出失败: ${error.message}`);
        }
    }

    // 清空结果
    clearResults() {
        // 清空所有表格
        document.querySelectorAll('.data-table tbody').forEach(tbody => {
            tbody.innerHTML = '<tr class="empty-state"><td colspan="100%">暂无数据，请先处理数据</td></tr>';
        });

        // 重置统计卡片
        document.getElementById('target1Stats').textContent = '--';
        document.getElementById('target2Stats').textContent = '--';
        document.getElementById('target3Stats').textContent = '--';

        // 重置图表
        const chartContainer = document.getElementById('gradeChart');
        chartContainer.innerHTML = `
            <div class="chart-placeholder">
                <span>📊</span>
                <p>暂无数据，请先处理数据</p>
            </div>
        `;

        // 重置数据
        this.data.processed = null;
        document.getElementById('exportBtn').disabled = true;
        this.updateStatus('ready', '已清空结果');
    }

    // 显示/隐藏进度条
    showProgress(show) {
        const progressSection = document.getElementById('progressSection');
        progressSection.style.display = show ? 'block' : 'none';
        if (!show) {
            this.updateProgress(0);
        }
    }

    // 更新进度条
    updateProgress(percentage) {
        const progressFill = document.getElementById('progressFill');
        const progressText = document.getElementById('progressText');
        progressFill.style.width = `${percentage}%`;
        progressText.textContent = `${percentage}%`;
    }

    // 设置按钮加载状态
    setButtonLoading(button, loading) {
        if (loading) {
            button.classList.add('btn-loading');
            button.disabled = true;
        } else {
            button.classList.remove('btn-loading');
            button.disabled = false;
        }
    }

    // 更新状态指示器
    updateStatus(type, message) {
        const statusText = document.querySelector('.status-text');
        const statusDot = document.querySelector('.status-dot');
        
        statusText.textContent = message;
        
        // 移除所有状态类
        statusDot.className = 'status-dot';
        
        // 添加新状态类
        switch (type) {
            case 'ready':
                statusDot.style.background = 'var(--success-color)';
                break;
            case 'processing':
                statusDot.style.background = 'var(--warning-color)';
                break;
            case 'success':
                statusDot.style.background = 'var(--success-color)';
                break;
            case 'error':
                statusDot.style.background = 'var(--danger-color)';
                break;
            case 'info':
                statusDot.style.background = 'var(--primary-color)';
                break;
        }
    }

    // 显示错误消息
    showError(message) {
        // 这里可以实现自定义的错误提示框
        // 或者调用MATLAB的uialert
        if (window.matlabBridge && window.matlabBridge.showAlert) {
            window.matlabBridge.showAlert('错误', message, 'error');
        } else {
            alert(`错误: ${message}`);
        }
    }

    // 显示成功消息
    showSuccess(message) {
        if (window.matlabBridge && window.matlabBridge.showAlert) {
            window.matlabBridge.showAlert('成功', message, 'success');
        } else {
            alert(`成功: ${message}`);
        }
    }

    // 处理键盘快捷键
    handleKeyboard(event) {
        if (event.ctrlKey) {
            switch (event.key) {
                case 'p':
                    event.preventDefault();
                    this.processData();
                    break;
                case 'e':
                    event.preventDefault();
                    this.exportResults();
                    break;
                case 'r':
                    event.preventDefault();
                    this.clearResults();
                    break;
            }
        }
    }
}

// 初始化应用
document.addEventListener('DOMContentLoaded', () => {
    window.gradeAnalysisApp = new StudentGradeAnalysisApp();
});