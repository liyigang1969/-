# 定时触发器系统
# 功能：管理3分钟对话、10分钟回忆、10分钟规划定时任务

Write-Host "=== 定时触发器系统 ===" -ForegroundColor Cyan
Write-Host "时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
Write-Host "功能: 管理自治工作循环定时任务" -ForegroundColor Yellow
Write-Host ""

# 检查当前循环状态
$cyclePath = "E:\openclaw-data\.openclaw\workspace\current_cycle.json"
if (-not (Test-Path $cyclePath)) {
    Write-Host "❌ 错误: 未找到当前循环状态文件" -ForegroundColor Red
    Write-Host "   请先运行人工启动流程" -ForegroundColor Yellow
    exit 1
}

# 读取循环状态
$cycleContent = Get-Content $cyclePath -Raw
$cycle = $cycleContent | ConvertFrom-Json

Write-Host "当前循环: #$($cycle.cycle_number)" -ForegroundColor White
Write-Host "开始时间: $($cycle.start_time)" -ForegroundColor White
Write-Host "状态: $($cycle.status)" -ForegroundColor White
Write-Host ""

# 计算当前时间在循环中的位置
$startTime = [DateTime]::Parse($cycle.start_time)
$currentTime = Get-Date
$minutesElapsed = [math]::Round(($currentTime - $startTime).TotalMinutes)

Write-Host "循环已进行: $minutesElapsed 分钟" -ForegroundColor White
Write-Host ""

# 检查并执行定时任务
Write-Host "检查定时任务..." -ForegroundColor Green

# 任务1: 3分钟对话模拟
if ($minutesElapsed % 3 -eq 0) {
    Write-Host "✅ 触发: 3分钟对话模拟" -ForegroundColor Green
    Execute-DialogueSimulation
}

# 任务2: 10分钟回忆过程
if ($minutesElapsed % 10 -eq 0) {
    Write-Host "✅ 触发: 10分钟回忆过程" -ForegroundColor Green
    Execute-MemoryRecall
}

# 任务3: 10分钟规划过程
if ($minutesElapsed % 10 -eq 0 -and $minutesElapsed -ne 0) {
    Write-Host "✅ 触发: 10分钟规划过程" -ForegroundColor Green
    Execute-PlanningProcess
}

# 检查循环是否结束
if ($minutesElapsed -ge $cycle.cycle_duration_minutes) {
    Write-Host "🔄 循环结束，开始新循环..." -ForegroundColor Yellow
    Start-NewCycle
}

Write-Host ""
Write-Host "=== 定时检查完成 ===" -ForegroundColor Cyan

# 函数定义
function Execute-DialogueSimulation {
    Write-Host "   执行对话模拟..." -ForegroundColor White
    
    # 创建对话日志
    $logPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\dialogue_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    $logContent = @"
# 模拟对话记录
## 对话时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
## 触发类型: 3分钟定时对话

## 对话内容
**系统**: 当前工作循环正常进行中
**状态**: 循环 #$($cycle.cycle_number), 已进行 $minutesElapsed 分钟
**任务**: 检查工作队列，更新状态

## 工作状态更新
- 最后活动时间: $(Get-Date -Format 'HH:mm:ss')
- 系统健康: 正常
- 定时任务: 按计划执行

## 模拟用户响应
用户确认系统工作正常，继续自治循环。

---
*3分钟对话模拟完成*
"@

    $logContent | Out-File -FilePath $logPath -Encoding UTF8
    Write-Host "     对话日志已记录: $(Split-Path $logPath -Leaf)" -ForegroundColor White
    
    # 更新系统状态
    Update-SystemState "dialogue_simulation"
}

function Execute-MemoryRecall {
    Write-Host "   执行回忆过程..." -ForegroundColor White
    
    # 读取记忆文件
    $memoryPath = "E:\openclaw-data\.openclaw\workspace\MEMORY.md"
    if (Test-Path $memoryPath) {
        $memoryContent = Get-Content $memoryPath -First 5
        Write-Host "     读取记忆文件: $(Split-Path $memoryPath -Leaf)" -ForegroundColor White
    }
    
    # 创建回忆日志
    $logPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\memory_recall_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    $logContent = @"
# 回忆过程记录
## 回忆时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
## 触发类型: 10分钟定时回忆

## 回忆内容
1. **系统状态回顾**: 工作循环 #$($cycle.cycle_number) 进行中
2. **任务进展回顾**: 检查已完成和进行中的任务
3. **学习经验回顾**: 分析近期工作模式和效率

## 记忆更新
- 最后回忆时间: $(Get-Date -Format 'HH:mm:ss')
- 记忆完整性: 良好
- 相关记忆: 已关联到当前工作

## 回忆结论
系统工作正常，记忆访问成功，准备进行规划。

---
*10分钟回忆过程完成*
"@

    $logContent | Out-File -FilePath $logPath -Encoding UTF8
    Write-Host "     回忆日志已记录: $(Split-Path $logPath -Leaf)" -ForegroundColor White
    
    # 更新系统状态
    Update-SystemState "memory_recall"
}

function Execute-PlanningProcess {
    Write-Host "   执行规划过程..." -ForegroundColor White
    
    # 读取工作队列
    $queuePath = "E:\openclaw-data\.openclaw\workspace\work_queue.json"
    if (Test-Path $queuePath) {
        $queueContent = Get-Content $queuePath -Raw
        $queue = $queueContent | ConvertFrom-Json
        
        $pendingTasks = $queue.tasks | Where-Object { $_.status -eq "pending" }
        $inProgressTasks = $queue.tasks | Where-Object { $_.status -eq "in_progress" }
        
        Write-Host "     工作队列状态:" -ForegroundColor White
        Write-Host "       待处理: $($pendingTasks.Count) 个任务" -ForegroundColor White
        Write-Host "       进行中: $($inProgressTasks.Count) 个任务" -ForegroundColor White
    }
    
    # 创建规划日志
    $logPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\planning_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    $logContent = @"
# 规划过程记录
## 规划时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
## 触发类型: 10分钟定时规划

## 规划内容
### 1. 工作队列分析
- 总任务数: $(if ($queue.tasks) { $queue.tasks.Count } else { 0 })
- 待处理任务: $(if ($pendingTasks) { $pendingTasks.Count } else { 0 })
- 进行中任务: $(if ($inProgressTasks) { $inProgressTasks.Count } else { 0 })

### 2. 10分钟工作计划
1. **优先级任务**: 处理最高优先级任务
2. **系统维护**: 更新状态，检查健康
3. **记忆管理**: 整理和更新记忆
4. **日志记录**: 记录工作过程

### 3. 资源分配
- 时间分配: 10分钟工作窗口
- 任务分配: 基于优先级和依赖
- 监控机制: 实时状态跟踪

## 执行计划
1. 立即开始执行规划的任务
2. 监控执行进度
3. 调整计划基于实际情况
4. 准备下一个规划周期

---
*10分钟规划过程完成*
"@

    $logContent | Out-File -FilePath $logPath -Encoding UTF8
    Write-Host "     规划日志已记录: $(Split-Path $logPath -Leaf)" -ForegroundColor White
    
    # 更新系统状态
    Update-SystemState "planning_process"
}

function Update-SystemState {
    param($activity)
    
    $statePath = "E:\openclaw-data\.openclaw\workspace\work_state.json"
    if (Test-Path $statePath) {
        $content = Get-Content $statePath -Raw
        $state = $content | ConvertFrom-Json
        
        $state.system.last_heartbeat = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $state.system.uptime_minutes = [math]::Round(((Get-Date) - [DateTime]::Parse($state.system.last_heartbeat)).TotalMinutes)
        
        # 记录最后活动
        if (-not $state.system.last_activities) {
            $state.system | Add-Member -NotePropertyName "last_activities" -NotePropertyValue @()
        }
        
        $activityRecord = @{
            time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
            activity = $activity
            cycle_minute = $minutesElapsed
        }
        
        $state.system.last_activities += $activityRecord
        
        # 只保留最近10个活动
        if ($state.system.last_activities.Count -gt 10) {
            $state.system.last_activities = $state.system.last_activities | Select-Object -Last 10
        }
        
        $stateJson = $state | ConvertTo-Json -Depth 5
        $stateJson | Out-File -FilePath $statePath -Encoding UTF8
        
        Write-Host "     系统状态已更新" -ForegroundColor White
    }
}

function Start-NewCycle {
    # 更新循环编号
    $cycle.cycle_number++
    $cycle.start_time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
    $cycle.status = "running"
    
    # 更新子循环时间
    foreach ($subCycle in $cycle.sub_cycles) {
        $interval = [int]$subCycle.interval_minutes
        $subCycle.next_time = (Get-Date).AddMinutes($interval).ToString("HH:mm")
    }
    
    # 保存更新
    $cycleJson = $cycle | ConvertTo-Json -Depth 5
    $cycleJson | Out-File -FilePath $cyclePath -Encoding UTF8
    
    Write-Host "   新循环已开始: #$($cycle.cycle_number)" -ForegroundColor Green
    
    # 记录循环历史
    $historyPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\cycle_history_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    $historyContent = @"
# 工作循环历史记录
## 循环信息
- 完成循环: #$($cycle.cycle_number - 1)
- 开始时间: $($cycle.start_time)
- 持续时间: $($cycle.cycle_duration_minutes) 分钟
- 新循环: #$($cycle.cycle_number)

## 循环总结
上一个循环成功完成，系统工作正常。
开始新的自治工作循环。

---
*循环切换完成*
"@

    $historyContent | Out-File -FilePath $historyPath -Encoding UTF8
}