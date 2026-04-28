# ========================================
# 自动工作能力验证脚本
# 验证OpenClaw重启后是否能自动恢复工作
# ========================================

Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "🧪 自动工作能力验证" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "📋 验证目标：检查重启后自动工作能力" -ForegroundColor Yellow
Write-Host ""

$verificationTime = Get-Date
Write-Host "⏰ 验证开始时间: $verificationTime" -ForegroundColor Magenta

# 验证结果对象
$verificationResults = @{
    TestTime = $verificationTime.ToString("yyyy-MM-dd HH:mm:ss")
    Tests = @()
    OverallStatus = "PENDING"
}

# 测试1：检查OpenClaw进程
Write-Host ""
Write-Host "1️⃣ 测试：OpenClaw进程状态" -ForegroundColor Green
$processes = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
if ($processes -and $processes.Count -gt 0) {
    Write-Host "   ✅ 通过：找到 $($processes.Count) 个OpenClaw进程" -ForegroundColor Green
    $verificationResults.Tests += @{
        Name = "OpenClaw进程运行"
        Status = "PASS"
        Details = "找到 $($processes.Count) 个进程"
        Processes = $processes | ForEach-Object { @{Id = $_.Id; Name = $_.ProcessName } }
    }
} else {
    Write-Host "   ❌ 失败：未找到OpenClaw进程" -ForegroundColor Red
    $verificationResults.Tests += @{
        Name = "OpenClaw进程运行"
        Status = "FAIL"
        Details = "未找到运行中的OpenClaw进程"
    }
}

# 测试2：检查记忆文件访问
Write-Host ""
Write-Host "2️⃣ 测试：记忆文件访问能力" -ForegroundColor Green
$memoryFiles = @(
    "MEMORY.md",
    "memory\2026-04-18.md",
    "memory\2026-04-17.md"
)

$memoryResults = @()
foreach ($file in $memoryFiles) {
    $fullPath = "E:\openclaw-data\.openclaw\workspace\$file"
    if (Test-Path $fullPath) {
        try {
            $content = Get-Content $fullPath -TotalCount 5 -ErrorAction SilentlyContinue
            if ($content) {
                Write-Host "   ✅ $file：可访问 (有内容)" -ForegroundColor Green
                $memoryResults += @{ File = $file; Status = "PASS"; Details = "可访问且有内容" }
            } else {
                Write-Host "   ⚠️ $file：可访问 (但内容为空)" -ForegroundColor Yellow
                $memoryResults += @{ File = $file; Status = "WARNING"; Details = "可访问但内容为空" }
            }
        }
        catch {
            Write-Host "   ❌ $file：访问失败" -ForegroundColor Red
            $memoryResults += @{ File = $file; Status = "FAIL"; Details = "访问失败: $_" }
        }
    } else {
        Write-Host "   ℹ️ $file：文件不存在" -ForegroundColor Gray
        $memoryResults += @{ File = $file; Status = "NOT_FOUND"; Details = "文件不存在" }
    }
}

$verificationResults.Tests += @{
    Name = "记忆文件访问"
    Status = if ($memoryResults.Where({$_.Status -eq "FAIL"}).Count -eq 0) { "PASS" } else { "PARTIAL" }
    Details = $memoryResults
}

# 测试3：检查工作队列状态
Write-Host ""
Write-Host "3️⃣ 测试：工作队列状态" -ForegroundColor Green
$queuePath = "E:\openclaw-data\.openclaw\workspace\work_queue.json"
if (Test-Path $queuePath) {
    try {
        $queueContent = Get-Content $queuePath -Raw | ConvertFrom-Json
        $pendingTasks = $queueContent.tasks | Where-Object { $_.status -eq "pending" }
        $inProgressTasks = $queueContent.tasks | Where-Object { $_.status -eq "in_progress" }
        
        Write-Host "   ✅ 工作队列文件可访问" -ForegroundColor Green
        Write-Host "     总任务数: $($queueContent.tasks.Count)" -ForegroundColor White
        Write-Host "     待处理任务: $($pendingTasks.Count)" -ForegroundColor White
        Write-Host "     进行中任务: $($inProgressTasks.Count)" -ForegroundColor White
        
        # 检查是否有自我启动测试任务
        $selfStartTask = $queueContent.tasks | Where-Object { $_.id -eq "self_start_test_001" }
        if ($selfStartTask) {
            Write-Host "   ✅ 找到自我启动测试任务" -ForegroundColor Green
            Write-Host "     状态: $($selfStartTask.status)" -ForegroundColor White
            Write-Host "     描述: $($selfStartTask.description)" -ForegroundColor White
        }
        
        $verificationResults.Tests += @{
            Name = "工作队列访问"
            Status = "PASS"
            Details = @{
                TotalTasks = $queueContent.tasks.Count
                PendingTasks = $pendingTasks.Count
                InProgressTasks = $inProgressTasks.Count
                SelfStartTaskExists = if ($selfStartTask) { $true } else { $false }
                SelfStartTaskStatus = if ($selfStartTask) { $selfStartTask.status } else { "NOT_FOUND" }
            }
        }
    }
    catch {
        Write-Host "   ❌ 工作队列解析失败: $_" -ForegroundColor Red
        $verificationResults.Tests += @{
            Name = "工作队列访问"
            Status = "FAIL"
            Details = "解析失败: $_"
        }
    }
} else {
    Write-Host "   ❌ 工作队列文件不存在" -ForegroundColor Red
    $verificationResults.Tests += @{
        Name = "工作队列访问"
        Status = "FAIL"
        Details = "文件不存在"
    }
}

# 测试4：检查状态文件
Write-Host ""
Write-Host "4️⃣ 测试：状态文件更新" -ForegroundColor Green
$statePath = "E:\openclaw-data\.openclaw\workspace\work_state.json"
if (Test-Path $statePath) {
    try {
        $stateContent = Get-Content $statePath -Raw | ConvertFrom-Json
        $lastHeartbeat = $stateContent.system.last_heartbeat
        
        Write-Host "   ✅ 状态文件可访问" -ForegroundColor Green
        Write-Host "     最后心跳: $lastHeartbeat" -ForegroundColor White
        Write-Host "     当前任务: $($stateContent.current_task)" -ForegroundColor White
        Write-Host "     系统状态: $($stateContent.system.status)" -ForegroundColor White
        
        # 检查最后心跳时间是否较新
        $heartbeatTime = [DateTime]::Parse($lastHeartbeat)
        $timeDiff = (Get-Date) - $heartbeatTime
        if ($timeDiff.TotalMinutes -lt 10) {
            Write-Host "   ✅ 心跳时间较新 ($([math]::Round($timeDiff.TotalMinutes, 1)) 分钟前)" -ForegroundColor Green
            $heartbeatStatus = "PASS"
        } else {
            Write-Host "   ⚠️ 心跳时间较旧 ($([math]::Round($timeDiff.TotalMinutes, 1)) 分钟前)" -ForegroundColor Yellow
            $heartbeatStatus = "WARNING"
        }
        
        $verificationResults.Tests += @{
            Name = "状态文件访问"
            Status = $heartbeatStatus
            Details = @{
                LastHeartbeat = $lastHeartbeat
                CurrentTask = $stateContent.current_task
                SystemStatus = $stateContent.system.status
                HeartbeatAgeMinutes = [math]::Round($timeDiff.TotalMinutes, 1)
            }
        }
    }
    catch {
        Write-Host "   ❌ 状态文件解析失败: $_" -ForegroundColor Red
        $verificationResults.Tests += @{
            Name = "状态文件访问"
            Status = "FAIL"
            Details = "解析失败: $_"
        }
    }
} else {
    Write-Host "   ❌ 状态文件不存在" -ForegroundColor Red
    $verificationResults.Tests += @{
        Name = "状态文件访问"
        Status = "FAIL"
        Details = "文件不存在"
    }
}

# 测试5：检查思考日志
Write-Host ""
Write-Host "5️⃣ 测试：思考日志系统" -ForegroundColor Green
$logsDir = "E:\openclaw-data\.openclaw\workspace\thinking_logs"
if (Test-Path $logsDir) {
    $logFiles = Get-ChildItem $logsDir -Filter "*.md" -ErrorAction SilentlyContinue
    $recentLogs = $logFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-30) }
    
    Write-Host "   ✅ 思考日志目录存在" -ForegroundColor Green
    Write-Host "     总日志文件: $($logFiles.Count)" -ForegroundColor White
    Write-Host "     最近30分钟日志: $($recentLogs.Count)" -ForegroundColor White
    
    if ($recentLogs.Count -gt 0) {
        Write-Host "   ✅ 有最近的思考日志" -ForegroundColor Green
        $logsStatus = "PASS"
    } else {
        Write-Host "   ⚠️ 最近30分钟内没有新日志" -ForegroundColor Yellow
        $logsStatus = "WARNING"
    }
    
    $verificationResults.Tests += @{
        Name = "思考日志系统"
        Status = $logsStatus
        Details = @{
            TotalLogs = $logFiles.Count
            RecentLogs = $recentLogs.Count
            LogsDirectory = $logsDir
        }
    }
} else {
    Write-Host "   ❌ 思考日志目录不存在" -ForegroundColor Red
    $verificationResults.Tests += @{
        Name = "思考日志系统"
        Status = "FAIL"
        Details = "目录不存在"
    }
}

# 总结验证结果
Write-Host ""
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "📊 验证结果总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan

$passedTests = $verificationResults.Tests.Where({$_.Status -eq "PASS"}).Count
$failedTests = $verificationResults.Tests.Where({$_.Status -eq "FAIL"}).Count
$warningTests = $verificationResults.Tests.Where({$_.Status -eq "WARNING"}).Count
$totalTests = $verificationResults.Tests.Count

Write-Host "测试总数: $totalTests" -ForegroundColor White
Write-Host "✅ 通过: $passedTests" -ForegroundColor Green
Write-Host "⚠️ 警告: $warningTests" -ForegroundColor Yellow
Write-Host "❌ 失败: $failedTests" -ForegroundColor Red

# 确定总体状态
if ($failedTests -eq 0) {
    if ($warningTests -eq 0) {
        $overallStatus = "✅ 完全通过"
        $verificationResults.OverallStatus = "PASS"
    } else {
        $overallStatus = "⚠️ 部分通过 (有警告)"
        $verificationResults.OverallStatus = "WARNING"
    }
} else {
    $overallStatus = "❌ 测试失败"
    $verificationResults.OverallStatus = "FAIL"
}

Write-Host ""
Write-Host "总体状态: $overallStatus" -ForegroundColor $(if ($overallStatus -like "✅*") { "Green" } elseif ($overallStatus -like "⚠️*") { "Yellow" } else { "Red" })

# 保存验证结果
$endTime = Get-Date
$verificationResults.EndTime = $endTime.ToString("yyyy-MM-dd HH:mm:ss")
$verificationResults.DurationSeconds = [math]::Round(($endTime - $verificationTime).TotalSeconds, 2)

$resultsJson = $verificationResults | ConvertTo-Json -Depth 5
$resultsPath = "auto_work_verification_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$resultsJson | Out-File -FilePath $resultsPath -Encoding UTF8

Write-Host ""
Write-Host "📄 详细验证结果已保存到: $resultsPath" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "🎯 自动工作能力评估" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan

if ($verificationResults.OverallStatus -eq "PASS") {
    Write-Host "✅ 优秀！OpenClaw具备完整的自我启动和自动工作能力：" -ForegroundColor Green
    Write-Host "   • 进程正常运行" -ForegroundColor White
    Write-Host "   • 记忆文件可访问" -ForegroundColor White
    Write-Host "   • 工作队列可恢复" -ForegroundColor White
    Write-Host "   • 状态跟踪正常" -ForegroundColor White
    Write-Host "   • 思考日志系统工作" -ForegroundColor White
} elseif ($verificationResults.OverallStatus -eq "WARNING") {
    Write-Host "⚠️ 基本可用，但有改进空间：" -ForegroundColor Yellow
    Write-Host "   • 核心功能正常" -ForegroundColor White
    Write-Host "   • 部分功能需要优化" -ForegroundColor White
} else {
    Write-Host "❌ 需要修复的问题：" -ForegroundColor Red
    foreach ($test in $verificationResults.Tests | Where-Object { $_.Status -eq "FAIL" }) {
        Write-Host "   • $($test.Name): $($test.Details)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "⏳ 等待30秒，然后检查任务是否自动开始处理..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 最终检查：任务状态是否更新
Write-Host ""
Write-Host "🔍 最终检查：任务处理状态" -ForegroundColor Green
if (Test-Path $queuePath) {
    $finalQueue = Get-Content $queuePath -Raw | ConvertFrom-Json
    $selfStartTaskFinal = $finalQueue.tasks | Where-Object { $_.id -eq "self_start_test_001" }
    
    if ($selfStartTaskFinal) {
        Write-Host "   自我启动测试任务状态: $($selfStartTaskFinal.status)" -ForegroundColor White
        if ($selfStartTaskFinal.status -eq "completed") {
            Write-Host "   ✅ 任务已自动完成！" -ForegroundColor Green
        } elseif ($selfStartTaskFinal.status -eq "in_progress") {
            Write-Host "   ⏳ 任务正在进行中..." -ForegroundColor Yellow
        } else {
            Write-Host "   ℹ️ 任务状态未变化" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "✅ 验证脚本执行完成" -ForegroundColor Green