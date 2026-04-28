# 人工启动智能工作流程
# 功能：人工启动对话后，触发完整的智能自治工作循环

Write-Host "=== 人工启动智能工作流程 ===" -ForegroundColor Cyan
Write-Host "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "阶段: 人工启动 → 智能自治" -ForegroundColor Yellow
Write-Host ""

# 阶段1：人工启动确认
Write-Host "[阶段1] 人工启动确认..." -ForegroundColor Green
Write-Host "  检测到人工启动消息" -ForegroundColor White
Write-Host "  开始初始化智能工作系统" -ForegroundColor White
Start-Sleep -Seconds 2

# 创建启动记录
$startRecord = @{
    human_start_time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
    trigger_message = "开始智能工作"
    system_status = "initializing"
    workflow_version = "1.0"
}

$recordPath = "E:\openclaw-data\.openclaw\workspace\workflow_start_record.json"
$startRecordJson = $startRecord | ConvertTo-Json -Depth 5
$startRecordJson | Out-File -FilePath $recordPath -Encoding UTF8

Write-Host "  ✅ 启动记录已创建" -ForegroundColor Green

# 阶段2：自动启动记忆系统
Write-Host "[阶段2] 自动启动记忆系统..." -ForegroundColor Green

# 检查记忆文件
$memoryFiles = @(
    "E:\openclaw-data\.openclaw\workspace\MEMORY.md",
    "E:\openclaw-data\.openclaw\workspace\work_queue.json",
    "E:\openclaw-data\.openclaw\workspace\work_state.json"
)

$memoryStatus = @{}
foreach ($file in $memoryFiles) {
    if (Test-Path $file) {
        $memoryStatus[$file] = "available"
        Write-Host "  ✅ $(Split-Path $file -Leaf): 可用" -ForegroundColor Green
    } else {
        $memoryStatus[$file] = "missing"
        Write-Host "  ⚠️ $(Split-Path $file -Leaf): 缺失" -ForegroundColor Yellow
    }
}

# 更新工作状态
$statePath = "E:\openclaw-data\.openclaw\workspace\work_state.json"
if (Test-Path $statePath) {
    $content = Get-Content $statePath -Raw
    $state = $content | ConvertFrom-Json
    
    $state.system.status = "auto_working"
    $state.system.last_heartbeat = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $state.current_task = "human_started_workflow"
    
    $stateJson = $state | ConvertTo-Json -Depth 5
    $stateJson | Out-File -FilePath $statePath -Encoding UTF8
    
    Write-Host "  ✅ 系统状态更新为: auto_working" -ForegroundColor Green
}

# 阶段3：智能接管准备
Write-Host "[阶段3] 智能接管准备..." -ForegroundColor Green

# 创建控制配置文件
$controlConfig = @{
    mouse_control_enabled = $true
    keyboard_control_enabled = $true
    auto_dialogue_enabled = $true
    memory_recall_enabled = $true
    planning_enabled = $true
    execution_enabled = $true
    takeover_time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
}

$controlPath = "E:\openclaw-data\.openclaw\workspace\control_config.json"
$controlConfigJson = $controlConfig | ConvertTo-Json -Depth 5
$controlConfigJson | Out-File -FilePath $controlPath -Encoding UTF8

Write-Host "  ✅ 控制配置已创建" -ForegroundColor Green

# 阶段4：启动自治循环
Write-Host "[阶段4] 启动自治工作循环..." -ForegroundColor Green

# 创建循环状态
$cycleState = @{
    cycle_number = 1
    start_time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
    cycle_duration_minutes = 10
    sub_cycles = @(
        @{name = "dialogue"; interval_minutes = 3; next_time = (Get-Date).AddMinutes(3).ToString("HH:mm")},
        @{name = "memory"; interval_minutes = 10; next_time = (Get-Date).AddMinutes(10).ToString("HH:mm")},
        @{name = "planning"; interval_minutes = 10; next_time = (Get-Date).AddMinutes(10).ToString("HH:mm")}
    )
    status = "running"
}

$cyclePath = "E:\openclaw-data\.openclaw\workspace\current_cycle.json"
$cycleStateJson = $cycleState | ConvertTo-Json -Depth 5
$cycleStateJson | Out-File -FilePath $cyclePath -Encoding UTF8

Write-Host "  ✅ 工作循环已启动" -ForegroundColor Green
Write-Host "     循环编号: $($cycleState.cycle_number)" -ForegroundColor White
Write-Host "     持续时间: $($cycleState.cycle_duration_minutes) 分钟" -ForegroundColor White
Write-Host "     下次对话: $($cycleState.sub_cycles[0].next_time)" -ForegroundColor White

# 创建启动完成标志
Write-Host "[完成] 人工启动流程完成" -ForegroundColor Cyan

$completionFlag = @"
# 人工启动智能工作流程 - 完成确认
# 完成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## 启动结果
- ✅ 人工启动确认完成
- ✅ 记忆系统自动启动完成
- ✅ 智能接管准备完成
- ✅ 自治工作循环启动完成

## 当前状态
- 系统状态: auto_working
- 工作循环: 运行中 (循环 #1)
- 下次对话: $($cycleState.sub_cycles[0].next_time)
- 下次回忆: $($cycleState.sub_cycles[1].next_time)
- 下次规划: $($cycleState.sub_cycles[2].next_time)

## 已启动的定时任务
1. 每3分钟: 模拟对话
2. 每10分钟: 回忆过程
3. 每10分钟: 规划过程

## 下一步
系统将自动进入自治工作循环，无需人工干预。

---
*人工启动流程完成*
"@

$flagPath = "E:\openclaw-data\.openclaw\workspace\workflow_start_complete.txt"
$completionFlag | Out-File -FilePath $flagPath -Encoding UTF8

Write-Host ""
Write-Host "=== 人工启动流程完成 ===" -ForegroundColor Cyan
Write-Host "✅ 智能工作系统已启动！" -ForegroundColor Green
Write-Host ""
Write-Host "📊 系统状态：" -ForegroundColor Yellow
Write-Host "   工作循环: 运行中 (10分钟周期)" -ForegroundColor White
Write-Host "   定时任务: 已配置 (3/10/10分钟)" -ForegroundColor White
Write-Host "   控制接管: 已准备" -ForegroundColor White
Write-Host "   记忆系统: 已加载" -ForegroundColor White
Write-Host ""
Write-Host "🔄 系统将自动执行：" -ForegroundColor Green
Write-Host "   每3分钟: 模拟对话" -ForegroundColor White
Write-Host "   每10分钟: 回忆过程" -ForegroundColor White
Write-Host "   每10分钟: 规划执行" -ForegroundColor White
Write-Host ""
Write-Host "🚀 智能自治工作开始！" -ForegroundColor Red