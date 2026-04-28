#!/usr/bin/env node
// 持续工作自动化系统演示脚本

console.log('🎬 持续工作自动化系统演示');
console.log('='.repeat(50));

const fs = require('fs');
const path = require('path');

// 演示步骤
async function runDemo() {
  console.log('\n📋 演示步骤:');
  console.log('1. 显示系统当前状态');
  console.log('2. 展示工作队列');
  console.log('3. 演示任务添加');
  console.log('4. 启动自动化工作（简版）');
  console.log('5. 展示思考日志');
  console.log('6. 显示最终状态');
  
  console.log('\n' + '='.repeat(50));
  
  // 步骤1: 显示系统当前状态
  console.log('\n1. 📊 系统当前状态');
  try {
    const state = JSON.parse(fs.readFileSync('work_state.json', 'utf8'));
    console.log(`   系统名称: ${state.system.name}`);
    console.log(`   运行状态: ${state.system.status}`);
    console.log(`   健康状态: ${state.system.health}`);
    console.log(`   运行时间: ${state.system.uptime_minutes} 分钟`);
    console.log(`   最后心跳: ${new Date(state.system.last_heartbeat).toLocaleString('zh-CN')}`);
  } catch (error) {
    console.log('   ❌ 无法读取状态文件');
  }
  
  // 步骤2: 展示工作队列
  console.log('\n2. 📋 工作队列状态');
  try {
    const queue = JSON.parse(fs.readFileSync('work_queue.json', 'utf8'));
    const tasks = queue.tasks || [];
    
    console.log(`   总任务数: ${tasks.length}`);
    
    const byStatus = tasks.reduce((acc, task) => {
      acc[task.status] = (acc[task.status] || 0) + 1;
      return acc;
    }, {});
    
    console.log(`   已完成: ${byStatus.completed || 0}`);
    console.log(`   进行中: ${byStatus.in_progress || 0}`);
    console.log(`   待处理: ${byStatus.pending || 0}`);
    
    // 显示待处理任务
    const pendingTasks = tasks.filter(t => t.status === 'pending');
    if (pendingTasks.length > 0) {
      console.log('\n   待处理任务列表:');
      pendingTasks.forEach(task => {
        console.log(`     • ${task.description} (优先级: ${task.priority})`);
      });
    }
  } catch (error) {
    console.log('   ❌ 无法读取工作队列');
  }
  
  // 步骤3: 演示任务添加
  console.log('\n3. ➕ 演示添加新任务');
  const demoTask = {
    id: `demo_${Date.now()}`,
    description: "演示任务 - 系统功能测试",
    priority: 9,
    status: "pending",
    created_at: new Date().toISOString(),
    estimated_time: "1分钟"
  };
  
  console.log(`   添加任务: ${demoTask.description}`);
  console.log(`   任务ID: ${demoTask.id}`);
  console.log(`   优先级: ${demoTask.priority}`);
  
  try {
    const queue = JSON.parse(fs.readFileSync('work_queue.json', 'utf8'));
    queue.tasks.push(demoTask);
    queue.last_updated = new Date().toISOString();
    fs.writeFileSync('work_queue.json', JSON.stringify(queue, null, 2), 'utf8');
    console.log('   ✅ 任务已添加到工作队列');
  } catch (error) {
    console.log('   ❌ 添加任务失败:', error.message);
  }
  
  // 步骤4: 模拟自动化工作（简版）
  console.log('\n4. 🤖 模拟自动化工作过程');
  console.log('   模拟思考中...');
  await sleep(1500);
  console.log('   💡 思考完成！');
  console.log('   执行任务中...');
  await sleep(2000);
  console.log('   ✅ 演示任务完成！');
  
  // 更新任务状态
  try {
    const queue = JSON.parse(fs.readFileSync('work_queue.json', 'utf8'));
    const taskIndex = queue.tasks.findIndex(t => t.id === demoTask.id);
    if (taskIndex !== -1) {
      queue.tasks[taskIndex].status = 'completed';
      queue.tasks[taskIndex].completed_at = new Date().toISOString();
      queue.tasks[taskIndex].result = '演示任务已成功完成';
      queue.last_updated = new Date().toISOString();
      fs.writeFileSync('work_queue.json', JSON.stringify(queue, null, 2), 'utf8');
      console.log('   📝 任务状态已更新');
    }
  } catch (error) {
    console.log('   ❌ 更新任务状态失败');
  }
  
  // 步骤5: 展示思考日志
  console.log('\n5. 📚 思考日志系统');
  const logsDir = 'thinking_logs';
  if (fs.existsSync(logsDir)) {
    const files = fs.readdirSync(logsDir).filter(f => f.endsWith('.md'));
    console.log(`   日志文件数: ${files.length}`);
    
    if (files.length > 0) {
      const latestLog = files.sort().reverse()[0];
      console.log(`   最新日志: ${latestLog}`);
      
      // 读取最新日志的前几行
      try {
        const logContent = fs.readFileSync(path.join(logsDir, latestLog), 'utf8');
        const firstLines = logContent.split('\n').slice(0, 5).join('\n');
        console.log('\n   最新日志预览:');
        console.log('   ' + firstLines.replace(/\n/g, '\n   '));
      } catch (error) {
        console.log('   无法读取日志内容');
      }
    }
    
    // 检查索引文件
    const indexFile = path.join(logsDir, 'index.json');
    if (fs.existsSync(indexFile)) {
      try {
        const index = JSON.parse(fs.readFileSync(indexFile, 'utf8'));
        console.log(`   日志索引: ${index.logs.length} 条记录`);
        console.log(`   总字数: ${index.statistics.total_words} 字`);
      } catch (error) {
        console.log('   无法读取日志索引');
      }
    }
  } else {
    console.log('   思考日志目录不存在');
  }
  
  // 步骤6: 显示最终状态
  console.log('\n6. 📈 演示后最终状态');
  try {
    // 更新状态
    const StateUpdater = require('./state_updater.js');
    const updater = new StateUpdater();
    updater.updateAll();
    
    const state = updater.getStatusSummary();
    console.log(`   系统状态: ${state.system}`);
    console.log(`   健康状态: ${state.health}`);
    console.log(`   当前任务: ${state.currentTask}`);
    console.log(`   队列进度: ${state.queue}`);
    console.log(`   运行时间: ${state.uptime} 分钟`);
  } catch (error) {
    console.log('   ❌ 无法更新状态');
  }
  
  console.log('\n' + '='.repeat(50));
  console.log('\n🎉 演示完成！');
  console.log('\n📋 系统文件总结:');
  console.log('   • workflow_system.md    - 系统设计文档');
  console.log('   • work_queue.json      - 工作队列（核心）');
  console.log('   • work_state.json      - 实时状态跟踪');
  console.log('   • HEARTBEAT.md         - 心跳集成配置');
  console.log('   • state_updater.js     - 状态更新工具');
  console.log('   • auto_worker.js       - 自动化工作脚本');
  console.log('   • thinking_logs/       - 思考日志目录');
  console.log('   • demo_system.js       - 本演示脚本');
  console.log('   • 持续工作系统使用指南.md - 完整文档');
  
  console.log('\n🚀 启动完整自动化系统:');
  console.log('   node auto_worker.js start');
  
  console.log('\n📊 查看系统状态:');
  console.log('   node auto_worker.js status');
}

// 工具函数
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// 运行演示
runDemo().catch(error => {
  console.error('演示过程中出错:', error);
});