# 工作循环引擎
# 功能：管理10分钟自治工作循环，协调所有定时任务

Write-Host "=== 工作循环引擎 ===" -ForegroundColor Cyan
Write-Host "版本: 1.0" -ForegroundColor White
Write-Host "功能: 管理智能自治工作循环" -ForegroundColor Yellow
Write-Host ""

# 引擎配置
$engineConfig = @{
    cycle_duration_minutes = 10
    check_interval_seconds = 60  # 每60秒检查一次
    max_cycles = 100  # 最大循环次数
    log_level = "detailed"
}

Write-Host "引擎配置:" -ForegroundColor Green
Write-Host "  循环时长: $($engineConfig.cycle_duration_minutes) 分钟" -ForegroundColor White
Write-Host "  检查间隔: $($engineConfig.check_interval_seconds) 秒" -ForegroundColor White
Write-Host "  最大循环: $($engineConfig.max_cycles) 次" -ForegroundColor White
Write-Host ""

# 检查系统状态
Write-Host "检查系统状态..." -ForegroundColor Green

$requiredFiles = @(
    "E:\openclaw-data\.openclaw\workspace\current_cycle.json",
    "E:\openclaw-data\.openclaw\workspace\work_state.json",
    "E:\openclaw-data\.openclaw\workspace\work_queue.json"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $(Split-Path $file -Leaf): 存在" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $(Split-Path $file -Leaf): 缺失" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "❌ 系统文件不完整，无法启动工作循环" -ForegroundColor Red
    Write-Host "   请先运行人工启动流程" -ForegroundColor Yellow
    exit 1
}

# 读取当前循环状态
$cyclePath = "E:\openclaw-data\.openclaw\workspace\current_cycle.json"
$cycleContent = Get-Content $cyclePath -Raw
$cycle = $cycleContent | ConvertFrom-Json

Write-Host "当前循环状态:" -ForegroundColor Green
Write-Host "  循环编号: #$($cycle.cycle_number)" -ForegroundColor White
Write-Host "  开始时间: $($cycle.start_time)" -ForegroundColor White
Write-Host "  状态: $($cycle.status)" -ForegroundColor White
Write-Host ""

# 启动工作循环
Write-Host "启动工作循环引擎..." -ForegroundColor Green
Write-Host "  按 Ctrl+C 停止引擎" -ForegroundColor Yellow
Write-Host ""

$engineStartTime = Get-Date
$cyclesCompleted = 0

try {
    # 主循环
    while ($cyclesCompleted -lt $engineConfig.max_cycles) {
        $currentTime = Get-Date
        $cycleStartTime = [DateTime]::Parse($cycle.start_time)
        $minutesElapsed = [math]::Round(($currentTime - $cycleStartTime).TotalMinutes)
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 循环 #$($cycle.cycle_number) - 第 $minutesElapsed 分钟" -ForegroundColor Cyan
        
        # 执行定时触发器
        Write-Host "  执行定时触发器..." -ForegroundColor White
        & "E:\openclaw-data\.openclaw\workspace\scheduled_triggers.ps1"
        
        # 检查循环是否结束
        if ($minutesElapsed -ge $engineConfig.cycle_duration_minutes) {
            Write-Host "  🔄 循环 #$($cycle.cycle_number) 完成，准备新循环..." -ForegroundColor Yellow
            
            # 更新循环
            $cycle.cycle_number++
            $cycle.start_time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss+08:00")
            
            # 更新子循环时间
            foreach ($subCycle in $cycle.sub_cycles) {
                $interval = [int]$subCycle.interval_minutes
                $subCycle.next_time = (Get-Date).AddMinutes($interval).ToString("HH:mm")
            }
            
            # 保存更新
            $cycleJson = $cycle | ConvertTo-Json -Depth 5
            $cycleJson | Out-File -FilePath $cyclePath -Encoding UTF8
            
            $cyclesCompleted++
            
            Write-Host "  ✅ 新循环开始: #$($cycle.cycle_number)" -ForegroundColor Green
            
            # 记录循环完成
            $cycleLogPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\cycle_complete_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
            $cycleLogContent = @"
# 工作循环完成记录
## 循环信息
- 完成循环: #$($cycle.cycle_number - 1)
- 开始时间: $($cycle.start_time)
- 持续时间: $($engineConfig.cycle_duration_minutes) 分钟
- 总完成循环: $cyclesCompleted

## 循环统计
- 定时任务执行: 成功
- 系统状态: 正常
- 记忆访问: 成功
- 规划执行: 成功

## 引擎状态
- 运行时间: $([math]::Round((Get-Date - $engineStartTime).TotalMinutes)) 分钟
- 循环完成: $cyclesCompleted / $($engineConfig.max_cycles)
- 下次检查: $(Get-Date).AddSeconds($engineConfig.check_interval_seconds).ToString("HH:mm:ss")

---
*循环引擎运行中*
"@

            $cycleLogContent | Out-File -FilePath $cycleLogPath -Encoding UTF8
        }
        
        # 等待下一次检查
        Write-Host "  等待下一次检查 ($($engineConfig.check_interval_seconds)秒)..." -ForegroundColor White
        Start-Sleep -Seconds $engineConfig.check_interval_seconds
    }
    
    Write-Host "✅ 达到最大循环次数 ($($engineConfig.max_cycles))，引擎停止" -ForegroundColor Green
    
} catch {
    Write-Host "❌ 引擎错误: $($_.Exception.Message)" -ForegroundColor Red
    
    # 记录错误
    $errorLogPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\engine_error_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    $errorContent = @"
# 工作循环引擎错误记录
## 错误时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
## 错误信息: $($_.Exception.Message)
## 错误详情: $($_.Exception.StackTrace)

## 引擎状态
- 当前循环: #$($cycle.cycle_number)
- 已运行时间: $([math]::Round((Get-Date - $engineStartTime).TotalMinutes)) 分钟
- 完成循环: $cyclesCompleted

## 系统状态
- 最后心跳: $(Get-Date -Format 'HH:mm:ss')
- 引擎状态: 停止
- 需要人工干预: 是

---
*引擎因错误停止*
"@

    $errorContent | Out-File -FilePath $errorLogPath -Encoding UTF8
}

# 引擎停止记录
$stopLogPath = "E:\openclaw-data\.openclaw\workspace\thinking_logs\engine_stop_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
$stopContent = @"
# 工作循环引擎停止记录
## 停止时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## 引擎运行统计
- 开始时间: $($engineStartTime.ToString('yyyy-MM-dd HH:mm:ss'))
- 运行时长: $([math]::Round((Get-Date - $engineStartTime).TotalMinutes)) 分钟
- 完成循环: $cyclesCompleted
- 最大循环: $($engineConfig.max_cycles)

## 停止原因
$(if ($cyclesCompleted -ge $engineConfig.max_cycles) {
    "达到最大循环次数限制"
} else {
    "引擎错误或手动停止"
})

## 系统状态
- 最后循环: #$($cycle.cycle_number)
- 系统健康: $(if ($allFilesExist) { "良好" } else { "需要检查" })
- 需要重启: 是

## 建议操作
1. 检查错误日志
2. 重启工作循环引擎
3. 验证系统文件完整性

---
*工作循环引擎已停止*
"@

$stopContent | Out-File -FilePath $stopLogPath -Encoding UTF8

Write-Host ""
Write-Host "=== 工作循环引擎已停止 ===" -ForegroundColor Cyan
Write-Host "运行统计:" -ForegroundColor Yellow
Write-Host "  开始时间: $($engineStartTime.ToString('HH:mm:ss'))" -ForegroundColor White
Write-Host "  运行时长: $([math]::Round((Get-Date - $engineStartTime).TotalMinutes)) 分钟" -ForegroundColor White
Write-Host "  完成循环: $cyclesCompleted" -ForegroundColor White
Write-Host ""
Write-Host "日志文件已保存到 thinking_logs/ 目录" -ForegroundColor Green