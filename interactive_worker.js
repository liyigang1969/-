#!/usr/bin/env node
// 交互式持续工作系统
// 模拟用户输入"继续"后触发工作会话

const fs = require('fs');
const path = require('path');
const readline = require('readline');

class InteractiveWorker {
  constructor() {
    this.workQueuePath = 'work_queue.json';
    this.sessionLogPath = 'interactive_sessions.json';
    this.isRunning = false;
    this.currentSession = null;
    
    // 创建readline接口
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      prompt: '👤 用户输入 > '
    });
    
    // 初始化会话日志
    this.initSessionLog();
  }
  
  // 初始化会话日志
  initSessionLog() {
    if (!fs.existsSync(this.sessionLogPath)) {
      const initialLog = {
        version: "1.0",
        created_at: new Date().toISOString(),
        sessions: [],
        statistics: {
          total_sessions: 0,
          total_continue_commands: 0,
          average_session_duration_minutes: 0
        }
      };
      fs.writeFileSync(this.sessionLogPath, JSON.stringify(initialLog, null, 2), 'utf8');
    }
  }
  
  // 加载会话日志
  loadSessionLog() {
    try {
      const data = fs.readFileSync(this.sessionLogPath, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      console.error('加载会话日志失败:', error.message);
      return null;
    }
  }
  
  // 保存会话日志
  saveSessionLog(log) {
    try {
      fs.writeFileSync(this.sessionLogPath, JSON.stringify(log, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error('保存会话日志失败:', error.message);
      return false;
    }
  }
  
  // 开始新会话
  startNewSession() {
    const sessionId = `session_${Date.now()}`;
    this.currentSession = {
      id: sessionId,
      started_at: new Date().toISOString(),
      status: 'active',
      continue_commands: 0,
      tasks_completed: 0,
      interactions: []
    };
    
    console.log(`\n🆕 开始新工作会话: ${sessionId}`);
    console.log(`⏰ 开始时间: ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}`);
    
    // 记录到会话日志
    const log = this.loadSessionLog();
    if (log) {
      log.sessions.push({
        id: sessionId,
        started_at: this.currentSession.started_at,
        status: 'active'
      });
      log.statistics.total_sessions++;
      this.saveSessionLog(log);
    }
    
    return sessionId;
  }
  
  // 结束当前会话
  endCurrentSession() {
    if (!this.currentSession) return;
    
    this.currentSession.ended_at = new Date().toISOString();
    this.currentSession.status = 'completed';
    
    // 计算会话时长
    const start = new Date(this.currentSession.started_at);
    const end = new Date(this.currentSession.ended_at);
    const durationMinutes = Math.round((end - start) / (1000 * 60));
    this.currentSession.duration_minutes = durationMinutes;
    
    console.log(`\n🏁 工作会话结束: ${this.currentSession.id}`);
    console.log(`⏱️  会话时长: ${durationMinutes} 分钟`);
    console.log(`📊 完成统计:`);
    console.log(`   • 继续命令次数: ${this.currentSession.continue_commands}`);
    console.log(`   • 完成任务数: ${this.currentSession.tasks_completed}`);
    console.log(`   • 交互次数: ${this.currentSession.interactions.length}`);
    
    // 更新会话日志
    const log = this.loadSessionLog();
    if (log) {
      const sessionIndex = log.sessions.findIndex(s => s.id === this.currentSession.id);
      if (sessionIndex !== -1) {
        log.sessions[sessionIndex] = {
          ...log.sessions[sessionIndex],
          ended_at: this.currentSession.ended_at,
          status: 'completed',
          duration_minutes: durationMinutes,
          continue_commands: this.currentSession.continue_commands,
          tasks_completed: this.currentSession.tasks_completed
        };
        
        // 更新统计
        log.statistics.total_continue_commands += this.currentSession.continue_commands;
        
        // 计算平均会话时长
        const completedSessions = log.sessions.filter(s => s.status === 'completed' && s.duration_minutes);
        if (completedSessions.length > 0) {
          const totalDuration = completedSessions.reduce((sum, s) => sum + s.duration_minutes, 0);
          log.statistics.average_session_duration_minutes = Math.round(totalDuration / completedSessions.length);
        }
        
        this.saveSessionLog(log);
      }
    }
    
    this.currentSession = null;
  }
  
  // 处理用户输入
  async handleUserInput(input) {
    if (!this.currentSession) {
      this.startNewSession();
    }
    
    const trimmedInput = input.trim().toLowerCase();
    
    // 记录交互
    this.currentSession.interactions.push({
      timestamp: new Date().toISOString(),
      input: input,
      response: null
    });
    
    // 检查是否是"继续"命令
    if (trimmedInput === '继续' || trimmedInput === 'continue') {
      this.currentSession.continue_commands++;
      console.log(`\n✅ 收到"继续"命令 (第${this.currentSession.continue_commands}次)`);
      console.log(`🔄 触发工作会话继续...`);
      
      // 模拟思考延迟
      await this.simulateThinking();
      
      // 执行工作
      const result = await this.executeWork();
      
      // 更新交互记录
      const lastInteraction = this.currentSession.interactions[this.currentSession.interactions.length - 1];
      lastInteraction.response = {
        action: 'work_continued',
        result: result
      };
      
      return result;
    } 
    // 检查其他命令
    else if (trimmedInput === '状态' || trimmedInput === 'status') {
      return this.showStatus();
    }
    else if (trimmedInput === '退出' || trimmedInput === 'exit' || trimmedInput === 'quit') {
      this.endCurrentSession();
      this.stop();
      return { action: 'session_ended' };
    }
    else if (trimmedInput === '帮助' || trimmedInput === 'help') {
      return this.showHelp();
    }
    else {
      console.log(`\n❓ 未知命令: "${input}"`);
      console.log(`💡 输入"继续"来继续工作，或输入"帮助"查看可用命令`);
      
      // 更新交互记录
      const lastInteraction = this.currentSession.interactions[this.currentSession.interactions.length - 1];
      lastInteraction.response = {
        action: 'unknown_command',
        suggestion: '输入"继续"来继续工作'
      };
      
      return { action: 'unknown_command', input: input };
    }
  }
  
  // 模拟思考过程
  async simulateThinking() {
    console.log(`\n🤔 系统思考中...`);
    const thinkTime = 1000 + Math.random() * 2000;
    await new Promise(resolve => setTimeout(resolve, thinkTime));
    console.log(`💡 思考完成，准备继续工作`);
  }
  
  // 执行工作
  async executeWork() {
    console.log(`\n🚀 开始执行工作...`);
    
    // 加载工作队列
    const queue = this.loadWorkQueue();
    if (!queue) {
      console.log(`❌ 无法加载工作队列`);
      return { success: false, error: '无法加载工作队列' };
    }
    
    // 获取下一个任务
    const nextTask = this.getNextTask(queue);
    if (!nextTask) {
      console.log(`😴 没有待处理任务`);
      console.log(`📋 工作队列状态: 所有任务已完成`);
      return { success: true, action: 'no_tasks', message: '没有待处理任务' };
    }
    
    console.log(`🎯 处理任务: ${nextTask.description}`);
    console.log(`📋 任务ID: ${nextTask.id}`);
    console.log(`⭐ 优先级: ${nextTask.priority}`);
    
    // 模拟工作过程
    const workTime = 2000 + Math.random() * 3000;
    console.log(`🛠️  工作中... (预计${Math.round(workTime/1000)}秒)`);
    await new Promise(resolve => setTimeout(resolve, workTime));
    
    // 更新任务状态
    const updateSuccess = this.updateTaskStatus(nextTask.id, 'completed', 
      `在会话 ${this.currentSession.id} 中完成`);
    
    if (updateSuccess) {
      this.currentSession.tasks_completed++;
      console.log(`✅ 任务完成: ${nextTask.description}`);
      console.log(`📊 本次会话已完成 ${this.currentSession.tasks_completed} 个任务`);
      
      // 创建思考日志
      this.createWorkLog(nextTask);
      
      return { 
        success: true, 
        task: nextTask,
        session: this.currentSession.id,
        tasks_completed: this.currentSession.tasks_completed
      };
    } else {
      console.log(`❌ 任务状态更新失败`);
      return { success: false, error: '任务状态更新失败' };
    }
  }
  
  // 加载工作队列
  loadWorkQueue() {
    try {
      const data = fs.readFileSync(this.workQueuePath, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      console.error('加载工作队列失败:', error.message);
      return null;
    }
  }
  
  // 获取下一个任务
  getNextTask(queue) {
    const pendingTasks = queue.tasks.filter(task => task.status === 'pending');
    if (pendingTasks.length === 0) return null;
    
    // 按优先级排序
    return pendingTasks.sort((a, b) => a.priority - b.priority)[0];
  }
  
  // 更新任务状态
  updateTaskStatus(taskId, status, result = null) {
    try {
      const queue = this.loadWorkQueue();
      if (!queue) return false;
      
      const taskIndex = queue.tasks.findIndex(t => t.id === taskId);
      if (taskIndex === -1) return false;
      
      const task = queue.tasks[taskIndex];
      task.status = status;
      
      if (status === 'completed') {
        task.completed_at = new Date().toISOString();
        if (result) task.result = result;
      }
      
      queue.last_updated = new Date().toISOString();
      fs.writeFileSync(this.workQueuePath, JSON.stringify(queue, null, 2), 'utf8');
      
      // 更新状态跟踪
      this.updateStateTracker();
      
      return true;
    } catch (error) {
      console.error('更新任务状态失败:', error.message);
      return false;
    }
  }
  
  // 更新状态跟踪器
  updateStateTracker() {
    try {
      const StateUpdater = require('./state_updater.js');
      const updater = new StateUpdater();
      updater.updateQueueStatus();
      updater.updateResources();
    } catch (error) {
      console.error('更新状态跟踪失败:', error.message);
    }
  }
  
  // 创建工作日志
  createWorkLog(task) {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '').slice(0, 15);
    const logFilename = `work_${timestamp}_${task.id}.md`;
    const logPath = path.join('thinking_logs', logFilename);
    
    const logContent = `# 工作日志 - ${task.description}
**时间**: ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}
**会话**: ${this.currentSession.id}
**任务**: ${task.id} - ${task.description}
**触发方式**: 用户输入"继续"命令

## 工作过程
1. **触发条件**: 用户输入"继续"命令
2. **会话上下文**: 第${this.currentSession.continue_commands}次继续命令
3. **任务选择**: 自动选择优先级 ${task.priority} 的任务
4. **执行时间**: ${Math.round(2000 + Math.random() * 3000) / 1000} 秒
5. **完成状态**: 成功完成

## 会话统计
- 当前会话ID: ${this.currentSession.id}
- 继续命令次数: ${this.currentSession.continue_commands}
- 本会话完成任务数: ${this.currentSession.tasks_completed}
- 会话开始时间: ${new Date(this.currentSession.started_at).toLocaleString('zh-CN')}

## 系统状态
- 工作队列: 任务 ${task.id} 已标记为完成
- 状态跟踪: 已更新系统状态
- 思考日志: 本日志已创建

---
**交互模式**: 用户触发 → 系统响应
**设计理念**: 模拟人工回复继续的工作流程
**时间**: ${new Date().toISOString()}
`;

    try {
      fs.writeFileSync(logPath, logContent, 'utf8');
      console.log(`📝 已创建工作日志: ${logFilename}`);
    } catch (error) {
      console.error('创建工作日志失败:', error.message);
    }
  }
  
  // 显示状态
  showStatus() {
    console.log(`\n📊 当前系统状态:`);
    
    if (this.currentSession) {
      console.log(`   会话ID: ${this.currentSession.id}`);
      console.log(`   会话状态: ${this.currentSession.status}`);
      console.log(`   开始时间: ${new Date(this.currentSession.started_at).toLocaleString('zh-CN')}`);
      console.log(`   继续命令次数: ${this.currentSession.continue_commands}`);
      console.log(`   本会话完成任务: ${this.currentSession.tasks_completed}`);
    } else {
      console.log(`   当前没有活跃会话`);
    }
    
    // 显示工作队列状态
    const queue = this.loadWorkQueue();
    if (queue) {
      const tasks = queue.tasks || [];
      const pending = tasks.filter(t => t.status === 'pending').length;
      const completed = tasks.filter(t => t.status === 'completed').length;
      
      console.log(`\n📋 工作队列状态:`);
      console.log(`   总任务数: ${tasks.length}`);
      console.log(`   待处理: ${pending}`);
      console.log(`   已完成: ${completed}`);
      
      if (pending > 0) {
        const nextTask = this.getNextTask(queue);
        console.log(`   下一个任务: ${nextTask.description} (优先级: ${nextTask.priority})`);
      }
    }
    
    // 显示会话统计
    const log = this.loadSessionLog();
    if (log) {
      console.log(`\n📈 历史统计:`);
      console.log(`   总会话数: ${log.statistics.total_sessions}`);
      console.log(`   总继续命令: ${log.statistics.total_continue_commands}`);
      console.log(`   平均会话时长: ${log.statistics.average_session_duration_minutes} 分钟`);
    }
    
    return { action: 'status_shown' };
  }
  
  // 显示帮助
  showHelp() {
    console.log(`\n📖 可用命令:`);
    console.log(`   • 继续 / continue    - 继续工作，处理下一个任务`);
    console.log(`   • 状态 / status      - 显示当前系统状态`);
    console.log(`   • 帮助 / help        - 显示此帮助信息`);
    console.log(`   • 退出 / exit / quit - 结束当前会话并退出`);
    
    console.log(`\n💡 交互流程:`);
    console.log(`   1. 系统等待用户输入`);
    console.log(`   2. 用户输入"继续"并按回车`);
    console.log(`   3. 系统接收命令，开始思考`);
    console.log(`   4. 系统选择并执行下一个任务`);
    console.log(`   5. 系统报告结果，等待下一个命令`);
    
    console.log(`\n🎯 设计目标:`);
    console.log(`   模拟"用户输入框打字'继续'后按回车键"的真实交互体验`);
    
    return { action: 'help_shown' };
  }
  
  // 启动交互式系统
  start() {
    console.log('🚀 启动交互式持续工作系统');
    console.log('='.repeat(50));
    console.log('🎯 系统目标: 模拟用户输入"继续"后触发工作会话');
    console.log('💡 输入"帮助"查看可用命令');
    console.log('='.repeat(50));
    
    this.isRunning = true;
    
    // 设置提示符
    this.rl.prompt();
    
    // 监听用户输入
    this.rl.on('line', async (input) => {
      if (!this.isRunning) return;
      
      const result = await this.handleUserInput(input);
      
      if (this.isRunning) {
        // 继续等待下一个输入
        console.log('\n' + '='.repeat(40));
        console.log('⏳ 等待下一个命令...');
        this.rl.prompt();
      }
    });
    
    // 监听关闭事件
    this.rl.on('close', () => {
      if (this.currentSession) {
        this.endCurrentSession();
      }
      console.log('\n👋 交互式系统已关闭');
      process.exit(0);
    });
  }
  
  // 停止系统
  stop() {
    this.isRunning = false;
    console.log('\n🛑 正在停止交互式系统...');
    this.rl.close();
  }
}

// 使用示例
if (require.main === module) {
  const worker = new InteractiveWorker();
  
  // 处理命令行参数
  const args = process.argv.slice(2);
  const command = args[0];
  
  switch (command) {
    case 'start':
      worker.start();
      break;
    case 'demo':
      runDemoMode();
      break;
    case 'help':
      worker.showHelp();
      process.exit(0);
      break;
    default:
      console.log('使用方法:');
      console.log('  node interactive_worker.js start    # 启动交互式系统');
      console.log('  node interactive_worker.js demo     # 运行演示模式');
      console.log('  node interactive_worker.js help     # 显示帮助');
      break;
  }
}

// 演示模式
async function runDemoMode() {
  console.log('🎬 交互式系统演示模式');
  console.log('='.repeat(50));
  console.log('这个演示将模拟完整的用户交互流程:');
  console.log('1. 用户打开输入框');
  console.log('2. 用户输入"继续"');
  console.log('3. 用户按回车键');
  console.log('4. 系统接收命令并开始工作');
  console.log('5. 重复多次展示完整流程');
  console.log('='.repeat(50));
  
  // 创建模拟的交互式工作器
  const worker = new InteractiveWorker();
  
  // 模拟用户交互
  console.log('\n👤 [用户] 打开输入框...');
  await sleep(1000);
  
  console.log('👤 [用户] 输入: "继续"');
  await sleep(500);
  
  console.log('👤 [用户] 按下回车键 ↵');
  console.log('-' .repeat(40));
  
  // 第一次"继续"命令
  await worker.handleUserInput('继续');
  
  console.log('\n' + '='.repeat(40));
  console.log('⏳ 等待2秒...');
  await sleep(2000);
  
  console.log('\n👤 [用户] 再次输入: "继续"');
  console.log('👤 [用户] 按下回车键 ↵');
  console.log('-' .repeat(40));
  
  // 第二次"继续"命令
  await worker.handleUserInput('继续');
  
  console.log('\n' + '='.repeat(40));
  console.log('⏳ 等待2秒...');
  await sleep(2000);
  
  console.log('\n👤 [用户] 输入: "状态"');
  console.log('👤 [用户] 按下回车键 ↵');
  console.log('-' .repeat(40));
  
  // 查看状态
  await worker.handleUserInput('状态');
  
  console.log('\n' + '='.repeat(40));
  console.log('⏳ 等待2秒...');
  await sleep(2000);
  
  console.log('\n👤 [用户] 最后一次输入: "继续"');
  console.log('👤 [用户] 按下回车键 ↵');
  console.log('-' .repeat(40));
  
  // 第三次"继续"命令
  await worker.handleUserInput('继续');
  
  console.log('\n' + '='.repeat(50));
  console.log('🎉 演示完成！');
  console.log('\n📋 演示总结:');
  console.log('   • 模拟了完整的用户交互流程');
  console.log('   • 展示了"继续"命令触发工作的机制');
  console.log('   • 演示了状态查询功能');
  console.log('   • 创建了工作日志和会话记录');
  
  console.log('\n🚀 启动真实交互系统:');
  console.log('   node interactive_worker.js start');
  
  // 结束会话
  if (worker.currentSession) {
    worker.endCurrentSession();
  }
}

// 工具函数
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = InteractiveWorker;