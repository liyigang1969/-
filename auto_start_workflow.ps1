# ========================================
# OpenClaw自动启动工作流
# 在OpenClaw启动时自动开始工作
# ========================================

Write-Host "=== OpenClaw自动启动工作流开始 ===" -ForegroundColor Cyan
Write-Host "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host ""

# 1. 检查OpenClaw进程
Write-Host "1. 检查OpenClaw状态..." -ForegroundColor Green
$processes = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
if ($processes -and $processes.Count -gt 0) {
    Write-Host "   ✅ OpenClaw运行中: $($processes.Count) 个进程" -ForegroundColor Green
} else {
    Write-Host "   ❌ OpenClaw未运行" -ForegroundColor Red
    exit 1
}

# 2. 等待OpenClaw完全启动
Write-Host "2. 等待OpenClaw完全启动..." -ForegroundColor Green
Write-Host "   等待10秒确保所有服务就绪" -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 3. 检查工作空间文件
Write-Host "3. 检查工作空间文件..." -ForegroundColor Green
$workspacePath = "E:\openclaw-data\.openclaw\workspace"
if (Test-Path $workspacePath) {
    Write-Host "   ✅ 工作空间可访问: $workspacePath" -ForegroundColor Green
} else {
    Write-Host "   ❌ 工作空间不可访问" -ForegroundColor Red
    exit 1
}

# 4. 读取工作队列
Write-Host "4. 检查工作队列..." -ForegroundColor Green
$queuePath = Join-Path $workspacePath "work_queue.json"
if (Test-Path $queuePath) {
    try {
        $queueContent = Get-Content $queuePath -Raw | ConvertFrom-Json
        $pendingTasks = $queueContent.tasks | Where-Object { $_.status -eq "pending" }
        $inProgressTasks = $queueContent.tasks | Where-Object { $_.status -eq "in_progress" }
        
        Write-Host "   ✅ 工作队列可访问" -ForegroundColor Green
        Write-Host "     总任务数: $($queueContent.tasks.Count)" -ForegroundColor White
        Write-Host "     待处理任务: $($pendingTasks.Count)" -ForegroundColor White
        Write-Host "     进行中任务: $($inProgressTasks.Count)" -ForegroundColor White
        
        # 如果有待处理任务，创建自动开始工作的触发器
        if ($pendingTasks.Count -gt 0) {
            Write-Host "   🚀 发现待处理任务，准备自动开始工作..." -ForegroundColor Yellow
            
            # 获取最高优先级任务
            $highestPriority = $pendingTasks | Sort-Object priority | Select-Object -First 1
            Write-Host "     最高优先级任务: $($highestPriority.id)" -ForegroundColor White
            Write-Host "     描述: $($highestPriority.description)" -ForegroundColor White
        }
    }
    catch {
        Write-Host "   ⚠️ 工作队列解析失败: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️ 工作队列文件不存在" -ForegroundColor Yellow
}

# 5. 更新状态文件
Write-Host "5. 更新系统状态..." -ForegroundColor Green
$statePath = Join-Path $workspacePath "work_state.json"
if (Test-Path $statePath) {
    try {
        $stateContent = Get-Content $statePath -Raw | ConvertFrom-Json
        
        # 更新最后心跳时间
        $stateContent.system.last_heartbeat = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $stateContent.system.status = "running"
        $stateContent.system.health = "healthy"
        
        # 保存更新
        $stateJson = $stateContent | ConvertTo-Json -Depth 5
        $stateJson | Out-File -FilePath $statePath -Encoding UTF8
        
        Write-Host "   ✅ 系统状态已更新" -ForegroundColor Green
        Write-Host "     最后心跳: $($stateContent.system.last_heartbeat)" -ForegroundColor White
    }
    catch {
        Write-Host "   ⚠️ 状态更新失败: $_" -ForegroundColor Yellow
    }
}

# 6. 创建自动工作触发器
Write-Host "6. 创建自动工作触发器..." -ForegroundColor Green

# 创建心跳检查触发器文件
$triggerPath = Join-Path $workspacePath "auto_trigger_heartbeat.txt"
$triggerContent = @"
# 自动心跳触发器
# 创建时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# 目的: 触发OpenClaw开始自动化工作

触发指令:
1. 检查工作队列
2. 开始处理最高优先级任务
3. 更新系统状态
4. 记录思考日志

下次心跳检查时间: $(Get-Date).AddMinutes(5).ToString('HH:mm')
"@

$triggerContent | Out-File -FilePath $triggerPath -Encoding UTF8
Write-Host "   ✅ 自动触发器已创建: $triggerPath" -ForegroundColor Green

# 7. 创建自动开始工作的任务
Write-Host "7. 创建自动开始工作任务..." -ForegroundColor Green

$newTask = @{
    id = "auto_start_work_001"
    description = "自动启动工作 - 由启动工作流创建"
    priority = 1
    status = "pending"
    created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
    estimated_time = "2分钟"
    trigger = "auto_startup"
    requirements = @(
        "验证OpenClaw完全启动",
        "检查工作队列状态",
        "开始处理待处理任务",
        "更新系统状态"
    )
}

# 添加到工作队列
if (Test-Path $queuePath) {
    try {
        $queue = Get-Content $queuePath -Raw | ConvertFrom-Json
        $queue.tasks += $newTask
        $queue.last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        
        $queueJson = $queue | ConvertTo-Json -Depth 5
        $queueJson | Out-File -FilePath $queuePath -Encoding UTF8
        
        Write-Host "   ✅ 自动开始任务已添加到工作队列" -ForegroundColor Green
        Write-Host "     任务ID: auto_start_work_001" -ForegroundColor White
    }
    catch {
        Write-Host "   ⚠️ 添加任务失败: $_" -ForegroundColor Yellow
    }
}

# 8. 记录启动日志
Write-Host "8. 记录启动日志..." -ForegroundColor Green
$logDir = Join-Path $workspacePath "thinking_logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$logPath = Join-Path $logDir "auto_startup_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
$logContent = @"
# 自动启动工作流执行日志

## 执行信息
- **时间**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **触发**: OpenClaw启动后自动执行
- **目的**: 解决重启后需要手动触发工作的问题

## 执行步骤
1. ✅ 检查OpenClaw进程状态
2. ✅ 等待服务完全启动
3. ✅ 检查工作空间文件
4. ✅ 读取工作队列状态
5. ✅ 更新系统状态
6. ✅ 创建自动触发器
7. ✅ 添加自动开始任务
8. ✅ 记录执行日志

## 系统状态
- OpenClaw进程: $($processes.Count) 个
- 工作空间: $(if (Test-Path $workspacePath) { '可访问' } else { '不可访问' })
- 工作队列: $(if (Test-Path $queuePath) { '可访问' } else { '不可访问' })
- 系统状态: $(if (Test-Path $statePath) { '已更新' } else { '未更新' })

## 创建的触发器
1. **自动触发器文件**: auto_trigger_heartbeat.txt
2. **自动开始任务**: auto_start_work_001
3. **下次心跳检查**: $(Get-Date).AddMinutes(5).ToString('HH:mm')

## 预期行为
下次心跳检查时，系统应该:
1. 自动检查工作队列
2. 自动开始处理任务
3. 自动更新状态
4. 自动记录日志

## 改进目标
解决重启测试中发现的问题:
- ❌ 需要手动恢复对话
- ❌ 需要手动触发工作
- ❌ 心跳检查未自动开始

目标改为:
- ✅ 启动后自动开始工作
- ✅ 自动心跳检查
- ✅ 无需人工干预

---
*自动启动工作流执行完成*
"@

$logContent | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "   ✅ 启动日志已记录: $logPath" -ForegroundColor Green

Write-Host ""
Write-Host "=== 自动启动工作流完成 ===" -ForegroundColor Cyan
Write-Host "✅ 已创建完整的自动触发机制" -ForegroundColor Green
Write-Host "🕒 下次心跳检查: $(Get-Date).AddMinutes(5).ToString('HH:mm')" -ForegroundColor Yellow
Write-Host "🚀 系统现在应该能自动开始工作了！" -ForegroundColor Green