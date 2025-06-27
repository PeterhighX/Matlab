// MATLAB桥接脚本 - 用于连接前端与MATLAB后端

class MatlabBridge {
    constructor() {
        this.initialized = false;
        this.htmlComponent = null;
        this.init();
    }

    init() {
        // 等待HTML组件准备就绪
        this.waitForMatlabComponent();
    }

    waitForMatlabComponent() {
        // 设置全局htmlComponent引用
        if (typeof window !== 'undefined') {
            window.htmlComponent = {
                Data: '',
                DataChangedFcn: null
            };
            
            // 设置数据变更通知
            Object.defineProperty(window.htmlComponent, 'Data', {
                get: function() { return this._data || ''; },
                set: function(value) {
                    this._data = value;
                    if (this.DataChangedFcn && typeof this.DataChangedFcn === 'function') {
                        this.DataChangedFcn({HTMLSource: value});
                    }
                    // 触发自定义事件用于调试
                    console.log('MATLAB Bridge Data Changed:', value);
                }
            });
        }

        this.initialized = true;
        console.log('MATLAB Bridge initialized');
    }

    // 文件选择
    selectFile(type, callback) {
        if (!this.initialized) {
            console.warn('MATLAB Bridge not initialized');
            return;
        }

        try {
            const data = JSON.stringify({
                action: 'selectFile',
                type: type
            });
            
            window.htmlComponent.Data = data;
            
            if (callback && typeof callback === 'function') {
                callback();
            }
        } catch (error) {
            console.error('Error in selectFile:', error);
        }
    }

    // 处理数据
    processData(scoreFile, weightFile, progressCallback) {
        if (!this.initialized) {
            console.warn('MATLAB Bridge not initialized');
            return Promise.reject(new Error('MATLAB Bridge not initialized'));
        }

        return new Promise((resolve, reject) => {
            try {
                const data = JSON.stringify({
                    action: 'processData',
                    scoreFile: scoreFile,
                    weightFile: weightFile
                });
                
                window.htmlComponent.Data = data;
                
                // 模拟处理过程（实际处理由MATLAB完成）
                if (progressCallback) {
                    let progress = 0;
                    const interval = setInterval(() => {
                        progress += 10;
                        progressCallback(progress);
                        if (progress >= 100) {
                            clearInterval(interval);
                        }
                    }, 200);
                }
                
                // 注意：实际的resolve应该由MATLAB回调触发
                setTimeout(() => resolve({success: true}), 3000);
                
            } catch (error) {
                console.error('Error in processData:', error);
                reject(error);
            }
        });
    }

    // 导出结果
    exportResults(data) {
        if (!this.initialized) {
            console.warn('MATLAB Bridge not initialized');
            return Promise.reject(new Error('MATLAB Bridge not initialized'));
        }

        return new Promise((resolve, reject) => {
            try {
                const requestData = JSON.stringify({
                    action: 'exportResults',
                    data: data
                });
                
                window.htmlComponent.Data = requestData;
                
                // 模拟导出过程
                setTimeout(() => resolve({success: true}), 1000);
                
            } catch (error) {
                console.error('Error in exportResults:', error);
                reject(error);
            }
        });
    }

    // 设置默认文件路径
    setDefaultPaths(scoreFile, weightFile) {
        console.log('Setting default paths:', {scoreFile, weightFile});
        
        // 由于这个方法会在页面加载时调用，需要等待DOM就绪
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                this.setPathsInternal(scoreFile, weightFile);
            });
        } else {
            this.setPathsInternal(scoreFile, weightFile);
        }
    }

    setPathsInternal(scoreFile, weightFile) {
        const scoreInput = document.getElementById('scoreFile');
        const weightInput = document.getElementById('weightFile');
        
        if (scoreInput && scoreFile) {
            scoreInput.value = scoreFile;
        }
        if (weightInput && weightFile) {
            weightInput.value = weightFile;
        }
        
        // 触发验证
        if (window.gradeAnalysisApp && window.gradeAnalysisApp.validateInputs) {
            window.gradeAnalysisApp.validateInputs();
        }
    }
}

// 创建全局桥接实例
window.matlabBridge = new MatlabBridge();

// 兼容性：创建matlabProxy别名
window.matlabProxy = {
    selectFile: (type) => window.matlabBridge.selectFile(type),
    processData: (scoreFile, weightFile) => window.matlabBridge.processData(scoreFile, weightFile),
    exportResults: (data) => window.matlabBridge.exportResults(data)
};

console.log('MATLAB Bridge script loaded'); 