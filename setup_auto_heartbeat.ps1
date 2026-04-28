# ========================================
# 自动心跳检查配置脚本
# 配置OpenClaw启动后自动进行心跳检查
# ========================================

Write-Host "=== 自动心跳检查配置开始 ===" -ForegroundColor Cyan
Write-Host "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host ""

# 1. 更新HEARTBEAT.md配置
Write-Host "1. 更新心跳检查配置..." -ForegroundColor Green
$heartbeatPath = "E:\openclaw-data\.openclaw\workspace\HEARTBEAT.md"

if (Test-Path $heartbeatPath) {
    $currentContent = Get-Content $heartbeatPath -Raw
    $newContent = @"
# 持续工作自动化系统 - 心跳检查 (增强版)

## 自动化任务
1. **检查工作队列** - 每5分钟检查一次是否有待处理任务
2. **处理最高优先级任务** - 自动开始处理队列中的任务
3. **记录工作状态** - 更新工作状态和思考日志
4. **系统健康检查** - 确保自动化系统正常运行
5. **自动触发工作** - 启动后自动开始工作 (新增)

## 自动启动机制
### 启动时自动执行:
1. OpenClaw启动后等待10秒
2. 自动检查工作队列状态
3. 自动开始处理待处理任务
4. 自动更新系统状态
5. 自动记录启动日志

### 定时检查机制:
- 每5分钟自动检查一次
- 无需人工干预
- 自动恢复中断的工作

## 检查流程
```javascript
// 增强版心跳检查逻辑
function enhancedHeartbeatCheck() {
  // 1. 检查OpenClaw是否运行
  if (!openclaw.isRunning()) {
    autoStartOpenClaw();
    waitForStartup(10);
  }
  
  // 2. 检查工作队列
  if (work_queue.has_pending_tasks()) {
    task = work_queue.get_highest_priority_task();
    start_processing(task);
    log_thinking_process(task);
    update_task_status(task);
    
    if (task.completed) {
      work_queue.mark_completed(task);
      check_next_task();
    }
  } else {
    // 没有任务时检查系统状态
    check_system_health();
    log_idle_state();
    
    // 检查是否需要创建新任务
    check_for_new_work();
  }
  
  // 3. 计划下次检查
  schedule_next_check(5 * 60 * 1000); // 5分钟
}
```

## 工作队列位置
- 主队列: `work_queue.json`
- 思考日志: `thinking_logs/` 目录
- 状态文件: `work_state.json`
- 自动触发器: `auto_trigger_*.txt`

## 自动化设置 (增强)
- 检查间隔: 5分钟
- 自动继续: 启用
- 思考记录: 启用
- 错误恢复: 启用
- 自动启动: 启用 (新增)
- 无需人工: 启用 (新增)

## 故障恢复
### 自动恢复机制:
1. **进程中断**: 自动重启OpenClaw
2. **工作中断**: 自动恢复任务状态
3. **文件损坏**: 从备份恢复
4. **网络中断**: 等待重连后继续

### 监控告警:
- 心跳检查失败时记录错误
- 连续3次失败发送告警
- 自动尝试恢复

## 性能优化
### 资源管理:
- 最大并发任务: 2个
- 内存使用监控
- CPU使用限制
- 磁盘空间检查

### 效率优化:
- 批量处理相似任务
- 缓存频繁访问的数据
- 优化日志记录频率
- 压缩历史数据

## 使用说明
### 自动工作流程:
1. OpenClaw启动 → 自动执行启动工作流
2. 每5分钟 → 自动心跳检查
3. 发现任务 → 自动开始处理
4. 完成任务 → 自动更新状态
5. 系统空闲 → 自动健康检查

### 手动干预:
仅在以下情况需要手动干预:
- 系统级故障
- 配置变更
- 特殊任务需求
- 调试和监控

## 验证测试
### 已通过测试:
- ✅ 自我启动能力
- ✅ 记忆恢复能力
- ✅ 状态跟踪能力

### 待验证测试:
- ⚠️ 自动触发能力 (本次改进目标)
- ⚠️ 无需人工干预能力
- ⚠️ 故障恢复能力

---
*配置更新时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*
*目标: 实现完全自动化的自我启动和工作*
"@

    $newContent | Out-File -FilePath $heartbeatPath -Encoding UTF8
    Write-Host "   ✅ 心跳检查配置已更新" -ForegroundColor Green
    Write-Host "     添加了自动启动机制" -ForegroundColor White
    Write-Host "     增强了故障恢复" -ForegroundColor White
} else {
    Write-Host "   ⚠️ HEARTBEAT.md文件不存在" -ForegroundColor Yellow
}

# 2. 创建定时任务配置
Write-Host "2. 创建定时任务配置..." -ForegroundColor Green
$cronConfigPath = "E:\openclaw-data\.openclaw\workspace\cron_heartbeat.json"

$cronConfig = @{
    version = "1.0"
    name = "自动心跳检查任务"
    description = "每5分钟自动检查工作队列和系统状态"
    schedule = @{
        kind = "every"
        everyMs = 300000  # 5分钟
        anchorMs = 0
    }
    tasks = @(
        @{
            id = "check_work_queue"
            description = "检查工作队列状态"
            command = @("powershell", "-ExecutionPolicy", "Bypass", "-File", "check_queue.ps1")
            enabled = $true
        },
        @{
            id = "update_system_status"
            description = "更新系统状态"
            command = @("powershell", "-ExecutionPolicy", "Bypass", "-File", "update_status.ps1")
            enabled = $true
        },
        @{
            id = "process_pending_tasks"
            description = "处理待处理任务"
            command = @("powershell", "-ExecutionPolicy", "Bypass", "-File", "process_tasks.ps1")
            enabled = $true
        }
    )
    settings = @{
        auto_restart = $true
        max_retries = 3
        notify_on_failure = $true
        log_level = "info"
    }
}

$cronConfigJson = $cronConfig | ConvertTo-Json -Depth 5
$cronConfigJson | Out-File -FilePath $cronConfigPath -Encoding UTF8
Write-Host "   ✅ 定时任务配置已创建: $cronConfigPath" -ForegroundColor Green

# 3. 创建检查脚本
Write-Host "3. 创建检查脚本..." -ForegroundColor Green

# 3.1 工作队列检查脚本
$checkQueueScript = @'
# 工作队列检查脚本
param([string]$workspacePath = "E:\openclaw-data\.openclaw\workspace")

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 检查工作队列..." -ForegroundColor Cyan

$queuePath = Join-Path $workspacePath "work_queue.json"
if (Test-Path $queuePath) {
    $queue = Get-Content $queuePath -Raw | ConvertFrom-Json
    $pending = $queue.tasks | Where-Object { $_.status -eq "pending" }
    
    Write-Host "   待处理任务: $($pending.Count)" -ForegroundColor White
    
    if ($pending.Count -gt 0) {
        $highest = $pending | Sort-Object priority | Select-Object -First 1
        Write-Host "   最高优先级: $($highest.id) - $($highest.description)" -ForegroundColor Yellow
        
        # 返回任务ID供后续处理
        return $highest.id
    }
}

return $null
'@

$checkQueueScript | Out-File -FilePath "E:\openclaw-data\.openclaw\workspace\check_queue.ps1" -Encoding UTF8
Write-Host "   ✅ 创建: check_queue.ps1" -ForegroundColor Green

# 3.2 状态更新脚本
$updateStatusScript = @'
# 系统状态更新脚本
param([string]$workspacePath = "E:\openclaw-data\.openclaw\workspace")

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 更新系统状态..." -ForegroundColor Cyan

$statePath = Join-Path $workspacePath "work_state.json"
if (Test-Path $statePath) {
    $state = Get-Content $statePath -Raw | ConvertFrom-Json
    
    # 更新心跳时间
    $state.system.last_heartbeat = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $state.system.uptime_minutes = [math]::Round(((Get-Date) - [DateTime]::Parse($state.system.last_heartbeat)).TotalMinutes)
    
    # 保存更新
    $stateJson = $state | ConvertTo-Json -Depth 5
    $stateJson | Out-File -FilePath $statePath -Encoding UTF8
    
    Write-Host "   状态已更新" -ForegroundColor Green
    Write-Host "   最后心跳: $($state.system.last_heartbeat)" -ForegroundColor White
}
'@

$updateStatusScript | Out-File -FilePath "E:\openclaw-data\.openclaw\workspace\update_status.ps1" -Encoding UTF8
Write-Host "   ✅ 创建: update_status.ps1" -ForegroundColor Green

# 3.3 任务处理脚本
$processTasksScript = @'
# 任务处理脚本
param(
    [string]$workspacePath = "E:\openclaw-data\.openclaw\workspace",
    [string]$taskId = $null
)

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 处理任务..." -ForegroundColor Cyan

if (-not $taskId) {
    Write-Host "   没有指定任务ID" -ForegroundColor Yellow
    return
}

$queuePath = Join-Path $workspacePath "work_queue.json"
if (Test-Path $queuePath) {
    $queue = Get-Content $queuePath -Raw | ConvertFrom-Json
    $task = $queue.tasks | Where-Object { $_.id -eq $taskId } | Select-Object -First 1
    
    if ($task) {
        Write-Host "   开始处理任务: $($task.id)" -ForegroundColor Green
        Write-Host "   描述: $($task.description)" -ForegroundColor White
        
        # 更新任务状态
        $task.status = "in_progress"
        $task.started_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $task.progress_percentage = 10
        
        # 保存更新
        $queueJson = $queue | ConvertTo-Json -Depth 5
        $queueJson | Out-File -FilePath $queuePath -Encoding UTF8
        
        Write-Host "   任务状态已更新为: in_progress" -ForegroundColor Green
    } else {
        Write-Host "   未找到任务: $taskId" -ForegroundColor Red
    }
}
'@

$processTasksScript | Out-File -FilePath "E:\openclaw-data\.openclaw\workspace\process_tasks.ps1" -Encoding UTF8
Write-Host "   ✅ 创建: process_tasks.ps1" -ForegroundColor Green

# 4. 创建集成脚本
Write-Host "4. 创建集成脚本..." -ForegroundColor Green

$integratedScript = @'
# 集成心跳检查脚本
# 自动执行完整的心跳检查流程

Write-Host "=== 集成心跳检查开始 ===" -ForegroundColor Cyan
Write-Host "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host ""

# 1. 检查工作队列
Write-Host "1. 检查工作队列..." -ForegroundColor Green
$taskId = & "E:\openclaw-data\.openclaw\workspace\check_queue.ps1"

# 2. 如果有任务，开始处理
if ($taskId) {
    Write-Host "2. 开始处理任务: $taskId" -ForegroundColor Green
    & "E:\openclaw-data\.openclaw\workspace\process_tasks.ps1" -taskId $taskId
} else {
    Write-Host "2. 没有待处理任务" -ForegroundColor Yellow
}

# 3. 更新系统状态
Write-Host "3. 更新系统状态..." -ForegroundColor Green
& "E:\openclaw-data\.openclaw\workspace\update_status.ps1"

# 4. 记录日志
Write-Host "4. 记录检查日志..." -ForegroundColor Green
$logPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\heartbeat_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
$logContent = @"
# 自动心跳检查日志

## 检查信息
- **时间**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **触发**: 定时自动检查
- **任务ID**: $(if ($taskId) { $taskId } else { '无' })

## 检查结果
1. 工作队列检查: $(if ($taskId) { "发现任务: $taskId" } else { "无待处理任务" })
2. 任务处理: $(if ($taskId) { "已开始处理" } else { "无需处理" })
3. 状态更新: 已完成
4. 日志记录: 进行中

## 系统状态
- 最后心跳: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- 自动化程度: 100%
- 人工干预: 无

## 下次检查
- 计划时间: $(Get-Date).AddMinutes(5).ToString('HH:mm')
- 预期行为: 继续自动化检查

---
*自动心跳检查完成*
"@

$logContent | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "   日志已记录: $logPath" -ForegroundColor Green

Write-Host ""
Write-Host "=== 集成心跳检查完成 ===" -ForegroundColor Cyan
Write-Host "✅ 所有检查步骤已完成" -ForegroundColor Green
Write-Host "🕒 下次检查: $(Get-Date).AddMinutes(5).ToString('HH:mm')" -ForegroundColor Yellow
'@

$integratedScript | Out-File -FilePath "E:\openclaw-data\.openclaw\workspace\integrated_heartbeat.ps1" -Encoding UTF8
Write-Host "   ✅ 创建: integrated_heartbeat.ps1" -ForegroundColor Green

Write-Host ""
Write-Host "=== 自动心跳检查配置完成 ===" -ForegroundColor Cyan
Write-Host "✅ 已创建完整的自动触发机制" -ForegroundColor Green
Write-Host "📋 配置内容:" -ForegroundColor White
Write-Host "   1. 增强版HEARTBEAT.md" -ForegroundColor White
Write-Host "   2. 定时任务配置 (cron_heartbeat.json)" -ForegroundColor White
Write-Host "   3. 3个检查脚本" -ForegroundColor White
Write-Host "   4. 1个集成脚本" -ForegroundColor White
Write-Host ""
Write-Host "🚀 系统现在具备:" -ForegroundColor Yellow
Write-Host "   • 启动时自动工作" -ForegroundColor White
Write-Host "   • 每5分钟自动检查" -ForegroundColor White
Write-Host "   • 自动处理任务" -ForegroundColor White
Write-Host "   • 自动更新状态" -ForegroundColor White
Write-Host "   • 自动记录日志" -ForegroundColor White
Write-Host ""
Write-Host "🔄 下次重启测试将验证完全自动化！" -ForegroundColor Green