#!/usr/bin/env node
// 简单的"继续"交互模拟
// 直接演示打字"继续"后按回车键的场景

const readline = require('readline');

console.log('🎯 目标演示: 模拟打字"继续"后按回车键');
console.log('='.repeat(50));
console.log('这个演示将展示完整的交互流程:');
console.log('1. 系统等待用户输入');
console.log('2. 用户输入"继续"');
console.log('3. 用户按回车键');
console.log('4. 系统触发工作会话');
console.log('='.repeat(50));
console.log('\n💡 提示: 请在下方输入"继续"并按回车键');
console.log('     或者输入"退出"结束演示');
console.log('='.repeat(50));

// 创建readline接口
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: '👤 请输入"继续"并按回车 > '
});

let sessionCount = 0;
let taskCount = 0;

// 模拟工作函数
async function simulateWork() {
  console.log('\n🤖 [系统] 收到"继续"命令...');
  console.log('🤔 [系统] 思考中...');
  
  // 模拟思考时间
  await sleep(1000 + Math.random() * 1000);
  
  console.log('💡 [系统] 思考完成!');
  console.log('🚀 [系统] 开始工作...');
  
  // 模拟工作时间
  await sleep(1500 + Math.random() * 1500);
  
  taskCount++;
  console.log(`✅ [系统] 工作完成! (已完成 ${taskCount} 个任务)`);
  console.log('📝 [系统] 已记录工作日志');
  
  // 更新状态
  updateSystemStatus();
}

// 更新系统状态
function updateSystemStatus() {
  const fs = require('fs');
  try {
    // 更新工作状态
    if (fs.existsSync('work_state.json')) {
      const state = JSON.parse(fs.readFileSync('work_state.json', 'utf8'));
      state.system.last_heartbeat = new Date().toISOString();
      state.system.uptime_minutes = Math.floor((new Date() - new Date(state.system.last_heartbeat)) / (1000 * 60));
      fs.writeFileSync('work_state.json', JSON.stringify(state, null, 2), 'utf8');
    }
    
    // 创建日志
    createInteractionLog();
  } catch (error) {
    // 忽略错误，继续演示
  }
}

// 创建交互日志
function createInteractionLog() {
  const fs = require('fs');
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const logContent = `# 交互日志 - 继续命令
**时间**: ${new Date().toLocaleString('zh-CN')}
**交互类型**: 用户输入"继续"命令
**会话次数**: ${sessionCount}
**完成任务数**: ${taskCount}

## 交互流程
1. 用户输入: "继续"
2. 用户动作: 按回车键
3. 系统响应: 检测到命令
4. 系统动作: 开始工作
5. 系统反馈: 工作完成

## 模拟效果
- 打字模拟: ✅ 完成
- 回车触发: ✅ 完成  
- 命令解析: ✅ 完成
- 工作执行: ✅ 完成
- 状态更新: ✅ 完成

---
**演示目标**: 模拟打字"继续"后按回车键
**完成状态**: 成功
**时间**: ${new Date().toISOString()}
`;

  const logDir = 'thinking_logs';
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
  
  const logPath = `${logDir}/interaction_${timestamp}.md`;
  fs.writeFileSync(logPath, logContent, 'utf8');
  console.log(`📁 [系统] 日志保存: ${logPath}`);
}

// 工具函数
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// 开始交互
rl.prompt();

rl.on('line', async (input) => {
  const trimmedInput = input.trim().toLowerCase();
  
  if (trimmedInput === '继续' || trimmedInput === 'continue') {
    sessionCount++;
    console.log(`\n✅ [系统] 第 ${sessionCount} 次收到"继续"命令`);
    console.log('↵ [系统] 检测到回车键按下!');
    
    await simulateWork();
    
    console.log('\n' + '='.repeat(40));
    console.log('⏳ 等待下一个命令...');
    console.log('💡 提示: 再次输入"继续"继续工作，或输入"退出"结束');
  } 
  else if (trimmedInput === '退出' || trimmedInput === 'exit' || trimmedInput === 'quit') {
    console.log(`\n📊 演示总结:`);
    console.log(`   会话次数: ${sessionCount}`);
    console.log(`   完成任务: ${taskCount}`);
    console.log(`   交互时间: ${new Date().toLocaleTimeString('zh-CN')}`);
    console.log('\n👋 演示结束，感谢使用!');
    rl.close();
    return;
  }
  else if (trimmedInput === '状态' || trimmedInput === 'status') {
    console.log(`\n📊 当前状态:`);
    console.log(`   会话次数: ${sessionCount}`);
    console.log(`   完成任务: ${taskCount}`);
    console.log(`   系统时间: ${new Date().toLocaleString('zh-CN')}`);
    console.log(`   输入提示: 输入"继续"继续工作`);
  }
  else if (trimmedInput === '帮助' || trimmedInput === 'help') {
    console.log(`\n📖 可用命令:`);
    console.log(`   • 继续 / continue - 触发工作会话`);
    console.log(`   • 状态 / status   - 查看当前状态`);
    console.log(`   • 退出 / exit     - 结束演示`);
    console.log(`   • 帮助 / help     - 显示此帮助`);
  }
  else if (trimmedInput === '') {
    // 空输入，忽略
  }
  else {
    console.log(`\n❓ 未知命令: "${input}"`);
    console.log(`💡 请输入"继续"来触发工作，或输入"帮助"查看可用命令`);
  }
  
  if (trimmedInput !== '退出' && trimmedInput !== 'exit' && trimmedInput !== 'quit') {
    rl.prompt();
  }
});

rl.on('close', () => {
  console.log('\n🔄 系统已关闭');
  process.exit(0);
});

// 显示初始提示
console.log('\n🎯 现在请尝试:');
console.log('   1. 将光标移到下方输入框');
console.log('   2. 输入汉字: "继续"');
console.log('   3. 按下回车键 ↵');
console.log('   4. 观察系统响应');
console.log('='.repeat(50));