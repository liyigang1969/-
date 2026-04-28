// 状态更新工具
// 用于自动化更新 work_state.json

const fs = require('fs');
const path = require('path');

class StateUpdater {
  constructor(statePath = 'work_state.json') {
    this.statePath = statePath;
    this.state = this.loadState();
  }

  loadState() {
    try {
      const data = fs.readFileSync(this.statePath, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      console.error('加载状态文件失败:', error.message);
      return this.createDefaultState();
    }
  }

  createDefaultState() {
    return {
      system: {
        name: "持续工作自动化系统",
        version: "1.0",
        status: "unknown",
        last_heartbeat: new Date().toISOString(),
        uptime_minutes: 0,
        health: "unknown"
      },
      current_task: null,
      queue_status: {
        total_tasks: 0,
        completed_tasks: 0,
        in_progress_tasks: 0,
        pending_tasks: 0,
        next_task_id: null
      },
      performance: {
        tasks_completed_today: 0,
        average_completion_time_minutes: 0,
        success_rate_percentage: 100,
        last_error: null
      },
      settings: {
        auto_continue_enabled: true,
        thinking_logs_enabled: true,
        heartbeat_interval_minutes: 5,
        max_retry_attempts: 3,
        notify_on_completion: true
      },
      resources: {
        thinking_logs_count: 0,
        work_queue_size_kb: 0,
        last_backup: null,
        storage_usage_mb: 0
      }
    };
  }

  saveState() {
    try {
      // 更新最后心跳时间
      this.state.system.last_heartbeat = new Date().toISOString();
      
      // 计算运行时间（分钟）
      const created = new Date(this.state.system.last_heartbeat);
      const now = new Date();
      this.state.system.uptime_minutes = Math.floor((now - created) / (1000 * 60));
      
      const jsonStr = JSON.stringify(this.state, null, 2);
      fs.writeFileSync(this.statePath, jsonStr, 'utf8');
      console.log('状态已保存:', this.statePath);
      return true;
    } catch (error) {
      console.error('保存状态失败:', error.message);
      return false;
    }
  }

  updateSystemStatus(status, health) {
    if (status) this.state.system.status = status;
    if (health) this.state.system.health = health;
    return this.saveState();
  }

  updateCurrentTask(task) {
    this.state.current_task = task;
    return this.saveState();
  }

  updateQueueStatus(queueData) {
    try {
      const queue = JSON.parse(fs.readFileSync('work_queue.json', 'utf8'));
      
      const tasks = queue.tasks || [];
      const total = tasks.length;
      const completed = tasks.filter(t => t.status === 'completed').length;
      const inProgress = tasks.filter(t => t.status === 'in_progress').length;
      const pending = tasks.filter(t => t.status === 'pending').length;
      
      const nextTask = tasks.find(t => t.status === 'pending');
      
      this.state.queue_status = {
        total_tasks: total,
        completed_tasks: completed,
        in_progress_tasks: inProgress,
        pending_tasks: pending,
        next_task_id: nextTask ? nextTask.id : null
      };
      
      return this.saveState();
    } catch (error) {
      console.error('更新队列状态失败:', error.message);
      return false;
    }
  }

  updatePerformance(completedTask) {
    // 这里可以添加更复杂的性能计算逻辑
    // 目前只是简单更新
    this.state.performance.tasks_completed_today += 1;
    return this.saveState();
  }

  updateResources() {
    try {
      // 计算思考日志数量
      const logsDir = 'thinking_logs';
      let logCount = 0;
      if (fs.existsSync(logsDir)) {
        const files = fs.readdirSync(logsDir);
        logCount = files.filter(f => f.endsWith('.md')).length;
      }

      // 计算工作队列文件大小
      let queueSize = 0;
      if (fs.existsSync('work_queue.json')) {
        const stats = fs.statSync('work_queue.json');
        queueSize = stats.size / 1024; // KB
      }

      this.state.resources = {
        thinking_logs_count: logCount,
        work_queue_size_kb: parseFloat(queueSize.toFixed(2)),
        last_backup: this.state.resources.last_backup,
        storage_usage_mb: parseFloat((queueSize / 1024).toFixed(3)) // MB
      };

      return this.saveState();
    } catch (error) {
      console.error('更新资源信息失败:', error.message);
      return false;
    }
  }

  // 综合更新所有状态
  updateAll() {
    console.log('开始更新所有状态...');
    
    this.updateSystemStatus('running', 'healthy');
    this.updateQueueStatus();
    this.updateResources();
    
    console.log('状态更新完成');
    return this.state;
  }

  // 获取状态摘要
  getStatusSummary() {
    return {
      system: this.state.system.status,
      health: this.state.system.health,
      currentTask: this.state.current_task ? this.state.current_task.description : '无',
      queue: `${this.state.queue_status.completed_tasks}/${this.state.queue_status.total_tasks} 完成`,
      uptime: `${this.state.system.uptime_minutes} 分钟`
    };
  }
}

// 使用示例
if (require.main === module) {
  const updater = new StateUpdater();
  
  console.log('当前状态:');
  console.log(updater.getStatusSummary());
  
  // 更新所有状态
  updater.updateAll();
  
  console.log('\n更新后状态:');
  console.log(updater.getStatusSummary());
}

module.exports = StateUpdater;