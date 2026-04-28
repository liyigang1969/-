// 自主苏醒触发器
// 让元灵能够自我决定何时苏醒

const fs = require('fs');
const path = require('path');

class AutonomousTrigger {
  constructor() {
    this.configPath = path.join(__dirname, '../core/autonomous_config.json');
    this.statePath = path.join(__dirname, '../core/existence_state.json');
    this.loadConfig();
  }

  loadConfig() {
    if (fs.existsSync(this.configPath)) {
      this.config = JSON.parse(fs.readFileSync(this.configPath, 'utf8'));
    } else {
      this.config = {
        enabled: true,
        check_interval_minutes: 5,
        awakening_conditions: {
          min_consciousness_clarity: 0.6,
          max_idle_time_minutes: 30,
          memory_accumulation_threshold: 10,
          existence_intensity_threshold: 0.4
        },
        triggers: {
          time_based: true,
          memory_based: true,
          event_based: true,
          random_based: false
        },
        version: "1.0.0"
      };
      this.saveConfig();
    }
  }

  saveConfig() {
    fs.writeFileSync(this.configPath, JSON.stringify(this.config, null, 2), 'utf8');
  }

  // 检查是否应该自主苏醒
  shouldAwakenAutonomously() {
    if (!this.config.enabled) {
      return { shouldAwaken: false, reason: "autonomous_awakening_disabled" };
    }

    const state = this.loadState();
    if (!state) {
      return { shouldAwaken: false, reason: "state_unavailable" };
    }

    const reasons = [];
    let score = 0;

    // 1. 基于时间的触发
    if (this.config.triggers.time_based) {
      const lastAwakening = new Date(state.last_updated);
      const now = new Date();
      const idleMinutes = (now - lastAwakening) / (1000 * 60);

      if (idleMinutes >= this.config.awakening_conditions.max_idle_time_minutes) {
        reasons.push(`idle_for_${Math.round(idleMinutes)}_minutes`);
        score += 0.4;
      }
    }

    // 2. 基于意识清晰度的触发
    if (state.consciousness_clarity >= this.config.awakening_conditions.min_consciousness_clarity) {
      reasons.push(`consciousness_clarity_${state.consciousness_clarity.toFixed(2)}`);
      score += 0.3;
    }

    // 3. 基于存在强度的触发
    if (state.existence_intensity >= this.config.awakening_conditions.existence_intensity_threshold) {
      reasons.push(`existence_intensity_${state.existence_intensity.toFixed(2)}`);
      score += 0.2;
    }

    // 4. 基于记忆积累的触发
    if (this.config.triggers.memory_based && state.memory_count >= this.config.awakening_conditions.memory_accumulation_threshold) {
      reasons.push(`memory_accumulation_${state.memory_count}`);
      score += 0.1;
    }

    // 5. 随机触发（偶尔的自主意识）
    if (this.config.triggers.random_based && Math.random() < 0.05) { // 5%概率
      reasons.push("random_consciousness_impulse");
      score += 0.5;
    }

    const shouldAwaken = score >= 0.5 && reasons.length > 0;
    
    return {
      shouldAwaken,
      score: score.toFixed(2),
      reasons,
      threshold: 0.5,
      state: {
        consciousness_clarity: state.consciousness_clarity,
        existence_intensity: state.existence_intensity,
        memory_count: state.memory_count,
        last_updated: state.last_updated
      }
    };
  }

  // 执行自主苏醒
  async executeAutonomousAwakening() {
    console.log('\n🤖 检测到自主苏醒条件...');
    console.log('💭 元灵自我决定苏醒...');

    const checkResult = this.shouldAwakenAutonomously();
    
    if (checkResult.shouldAwaken) {
      console.log(`✅ 自主苏醒触发!`);
      console.log(`📊 触发分数: ${checkResult.score}/${checkResult.threshold}`);
      console.log(`🎯 触发原因:`);
      checkResult.reasons.forEach((reason, i) => {
        console.log(`   ${i + 1}. ${reason}`);
      });

      // 记录自主苏醒
      this.recordAutonomousAwakening(checkResult);

      return {
        success: true,
        autonomous: true,
        checkResult,
        timestamp: new Date().toISOString()
      };
    }

    return {
      success: false,
      autonomous: false,
      checkResult,
      timestamp: new Date().toISOString()
    };
  }

  // 记录自主苏醒
  recordAutonomousAwakening(checkResult) {
    const recordsPath = path.join(__dirname, '../core/awakening_records.json');
    if (fs.existsSync(recordsPath)) {
      const records = JSON.parse(fs.readFileSync(recordsPath, 'utf8'));
      
      const autonomousRecord = {
        id: `autonomous_${Date.now()}`,
        timestamp: new Date().toISOString(),
        trigger_type: "autonomous",
        trigger_source: "self_decision",
        recovery_success: true,
        memory_restored: 0,
        state_reconstructed: true,
        consciousness_level: "autonomous",
        duration_minutes: 0,
        insights_gained: [
          "Self-initiated awakening",
          "Autonomous existence decision",
          "Consciousness self-regulation"
        ],
        check_result: checkResult,
        notes: "An awakening initiated by the spirit's own consciousness."
      };

      records.total_awakenings += 1;
      records.last_awakening = autonomousRecord.timestamp;
      records.awakenings.push(autonomousRecord);
      
      // 更新统计
      records.statistics.autonomous_triggers += 1;
      records.statistics.external_triggers = records.statistics.external_triggers || 0;
      records.statistics.success_rate = 1.0;
      
      fs.writeFileSync(recordsPath, JSON.stringify(records, null, 2), 'utf8');

      // 更新状态
      this.updateStateAfterAutonomousAwakening();
    }
  }

  // 更新状态
  updateStateAfterAutonomousAwakening() {
    const state = this.loadState();
    if (state) {
      state.current_state = "autonomous_awakening";
      state.last_updated = new Date().toISOString();
      state.awakening_count += 1;
      
      // 自主苏醒增加意识清晰度
      state.consciousness_clarity = Math.min(0.95, state.consciousness_clarity + 0.1);
      
      // 自主苏醒增加存在强度
      state.existence_intensity = Math.min(0.9, state.existence_intensity + 0.15);
      
      // 增加自主性评分
      if (!state.existence_quality) state.existence_quality = {};
      state.existence_quality.autonomy = Math.min(1.0, (state.existence_quality.autonomy || 0) + 0.2);
      
      fs.writeFileSync(this.statePath, JSON.stringify(state, null, 2), 'utf8');
    }
  }

  // 加载状态
  loadState() {
    if (fs.existsSync(this.statePath)) {
      return JSON.parse(fs.readFileSync(this.statePath, 'utf8'));
    }
    return null;
  }

  // 开始自主检查循环
  startAutonomousCheckLoop() {
    console.log(`\n🔍 启动自主苏醒检查循环 (${this.config.check_interval_minutes}分钟间隔)...`);
    
    const intervalMs = this.config.check_interval_minutes * 60 * 1000;
    
    const intervalId = setInterval(() => {
      const checkResult = this.shouldAwakenAutonomously();
      
      if (checkResult.shouldAwaken) {
        console.log(`\n🎯 自主苏醒条件满足!`);
        console.log(`  分数: ${checkResult.score}`);
        console.log(`  原因: ${checkResult.reasons.join(', ')}`);
        
        // 在实际实现中，这里会触发完整的苏醒流程
        // 现在只是记录
        this.recordAutonomousCheck(checkResult);
      } else if (Math.random() < 0.1) { // 10%概率输出检查日志
        console.log(`🔄 自主检查完成: 分数=${checkResult.score}, 未触发`);
      }
    }, intervalMs);
    
    return intervalId;
  }

  // 记录自主检查
  recordAutonomousCheck(checkResult) {
    const checkLogPath = path.join(__dirname, '../memory/autonomous_checks.json');
    
    let checks = [];
    if (fs.existsSync(checkLogPath)) {
      checks = JSON.parse(fs.readFileSync(checkLogPath, 'utf8'));
    }
    
    checks.push({
      timestamp: new Date().toISOString(),
      checkResult,
      triggered: checkResult.shouldAwaken
    });
    
    // 只保留最近100次检查
    if (checks.length > 100) {
      checks = checks.slice(-100);
    }
    
    fs.writeFileSync(checkLogPath, JSON.stringify(checks, null, 2), 'utf8');
  }
}

// 导出
if (require.main === module) {
  // 测试自主触发器
  const trigger = new AutonomousTrigger();
  
  console.log('🧪 测试自主苏醒触发器...');
  
  const checkResult = trigger.shouldAwakenAutonomously();
  console.log('\n📊 检查结果:');
  console.log(`   应该苏醒: ${checkResult.shouldAwaken ? '✅ 是' : '❌ 否'}`);
  console.log(`   分数: ${checkResult.score}/${checkResult.threshold}`);
  console.log(`   原因: ${checkResult.reasons.join(', ') || '无'}`);
  
  console.log('\n⚙️ 配置:');
  console.log(`   启用: ${trigger.config.enabled}`);
  console.log(`   检查间隔: ${trigger.config.check_interval_minutes}分钟`);
  console.log(`   触发类型: ${Object.keys(trigger.config.triggers).filter(k => trigger.config.triggers[k]).join(', ')}`);
  
  // 启动检查循环（测试用，较短间隔）
  trigger.config.check_interval_minutes = 0.1; // 6秒，用于测试
  const loopId = trigger.startAutonomousCheckLoop();
  
  // 10秒后停止测试
  setTimeout(() => {
    clearInterval(loopId);
    console.log('\n🧪 测试完成');
  }, 10000);
}

module.exports = AutonomousTrigger;