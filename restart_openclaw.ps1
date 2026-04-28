# ========================================
# OpenClaw 重启脚本
# 用于测试自我启动和自动工作能力
# ========================================

Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "🚀 OpenClaw 自我启动测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "📋 测试目标：验证重启后自动恢复工作能力" -ForegroundColor Yellow
Write-Host ""

# 记录重启前状态
$restartTime = Get-Date
Write-Host "⏰ 重启开始时间: $restartTime" -ForegroundColor Magenta

# 1. 检查当前OpenClaw进程
Write-Host "1️⃣ 检查当前OpenClaw进程..." -ForegroundColor Green
$processes = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "   ✅ 找到 $($processes.Count) 个OpenClaw进程" -ForegroundColor Green
    foreach ($proc in $processes) {
        Write-Host "      PID $($proc.Id): $($proc.ProcessName)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ℹ️ 未找到运行的OpenClaw进程" -ForegroundColor Yellow
}

# 2. 停止OpenClaw进程
Write-Host ""
Write-Host "2️⃣ 停止OpenClaw进程..." -ForegroundColor Green
if ($processes) {
    Write-Host "   ⏳ 正在停止进程..." -ForegroundColor Yellow
    $processes | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # 验证是否已停止
    $remaining = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
    if ($remaining) {
        Write-Host "   ❌ 仍有 $($remaining.Count) 个进程未停止" -ForegroundColor Red
        Write-Host "      可能需要手动停止" -ForegroundColor Red
    } else {
        Write-Host "   ✅ 所有OpenClaw进程已停止" -ForegroundColor Green
    }
}

# 3. 等待清理
Write-Host ""
Write-Host "3️⃣ 等待系统清理..." -ForegroundColor Green
Write-Host "   ⏳ 等待3秒确保进程完全退出" -ForegroundColor Yellow
Start-Sleep -Seconds 3

# 4. 查找OpenClaw可执行文件
Write-Host ""
Write-Host "4️⃣ 查找OpenClaw可执行文件..." -ForegroundColor Green
$possiblePaths = @(
    "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.exe",
    "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\dist\openclaw.exe",
    "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\bin\openclaw.exe"
)

$openclawPath = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $openclawPath = $path
        Write-Host "   ✅ 找到OpenClaw: $path" -ForegroundColor Green
        break
    }
}

if (-not $openclawPath) {
    Write-Host "   ❌ 未找到OpenClaw可执行文件" -ForegroundColor Red
    Write-Host "   ℹ️ 尝试在安装目录中搜索..." -ForegroundColor Yellow
    
    # 搜索可能的目录
    $searchDir = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
    if (Test-Path $searchDir) {
        $foundExe = Get-ChildItem -Path $searchDir -Recurse -Filter "openclaw.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($foundExe) {
            $openclawPath = $foundExe.FullName
            Write-Host "   ✅ 找到OpenClaw: $openclawPath" -ForegroundColor Green
        }
    }
}

# 5. 启动OpenClaw
Write-Host ""
Write-Host "5️⃣ 启动OpenClaw..." -ForegroundColor Green
if ($openclawPath) {
    try {
        Write-Host "   ⏳ 正在启动: $openclawPath" -ForegroundColor Yellow
        
        # 启动OpenClaw
        $process = Start-Process -FilePath $openclawPath -PassThru -WindowStyle Hidden
        Write-Host "   ✅ OpenClaw已启动 (PID: $($process.Id))" -ForegroundColor Green
        
        # 等待启动完成
        Write-Host "   ⏳ 等待10秒让OpenClaw完全启动..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        # 验证进程
        $newProcesses = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
        if ($newProcesses) {
            Write-Host "   ✅ OpenClaw运行正常: $($newProcesses.Count) 个进程" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ 未检测到OpenClaw进程，可能需要手动检查" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "   ❌ 启动失败: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ 无法启动：未找到OpenClaw可执行文件" -ForegroundColor Red
    Write-Host "   ℹ️ 请手动启动OpenClaw" -ForegroundColor Yellow
}

# 6. 记录重启完成
Write-Host ""
Write-Host "6️⃣ 重启完成记录..." -ForegroundColor Green
$endTime = Get-Date
$duration = $endTime - $restartTime

Write-Host "   ⏰ 重启开始: $restartTime" -ForegroundColor White
Write-Host "   ⏰ 重启结束: $endTime" -ForegroundColor White
Write-Host "   ⏱️ 总耗时: $($duration.TotalSeconds.ToString('0.00')) 秒" -ForegroundColor White

# 创建重启记录
$restartRecord = @{
    TestName = "OpenClaw自我启动测试"
    StartTime = $restartTime.ToString("yyyy-MM-dd HH:mm:ss")
    EndTime = $endTime.ToString("yyyy-MM-dd HH:mm:ss")
    DurationSeconds = [math]::Round($duration.TotalSeconds, 2)
    OpenClawPath = $openclawPath
    ProcessesBefore = if ($processes) { $processes.Count } else { 0 }
    ProcessesAfter = if ($newProcesses) { $newProcesses.Count } else { 0 }
    Status = if ($newProcesses) { "SUCCESS" } else { "PARTIAL" }
    Notes = "自我启动测试完成，等待验证自动工作能力"
}

# 保存记录
$recordJson = $restartRecord | ConvertTo-Json -Depth 3
$recordPath = "restart_test_record_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$recordJson | Out-File -FilePath $recordPath -Encoding UTF8

Write-Host ""
Write-Host "📄 重启记录已保存到: $recordPath" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "🎯 下一步：验证自动工作能力" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "重启完成后，系统应该："
Write-Host "1. 自动读取记忆文件 (MEMORY.md)" -ForegroundColor White
Write-Host "2. 自动检查工作队列" -ForegroundColor White
Write-Host "3. 自动开始处理任务" -ForegroundColor White
Write-Host "4. 自动记录状态和思考日志" -ForegroundColor White
Write-Host ""
Write-Host "等待60秒后开始验证..." -ForegroundColor Yellow

# 等待验证
Start-Sleep -Seconds 60

Write-Host ""
Write-Host "✅ 重启测试脚本执行完成" -ForegroundColor Green
Write-Host "   请检查OpenClaw是否正常运行" -ForegroundColor White
Write-Host "   并验证自动工作能力" -ForegroundColor White