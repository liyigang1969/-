# 防中断测试脚本 - 手工模拟保障自主工作不中断
# 创建时间: 2026-04-18 17:11:00
# 创建目的: 测试手工模拟防中断技术，保障自主工作不中断

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   防中断测试脚本启动 - 手工模拟测试" -ForegroundColor Yellow
Write-Host "   创建时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# 加载Windows Forms程序集用于键盘模拟
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Write-Host "✅ Windows Forms程序集加载成功" -ForegroundColor Green
} catch {
    Write-Host "❌ Windows Forms程序集加载失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== 测试配置 ===" -ForegroundColor Cyan
$testDuration = 300  # 测试总时长（秒）
$heartbeatInterval = 60  # 心跳间隔（秒）
$totalHeartbeats = [math]::Ceiling($testDuration / $heartbeatInterval)

Write-Host "测试总时长: $testDuration 秒 ($($testDuration/60) 分钟)" -ForegroundColor White
Write-Host "心跳间隔: $heartbeatInterval 秒" -ForegroundColor White
Write-Host "预计心跳次数: $totalHeartbeats 次" -ForegroundColor White
Write-Host ""

Write-Host "=== 测试开始 ===" -ForegroundColor Green
Write-Host "按 Ctrl+C 可随时停止测试" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
$heartbeatCount = 0

try {
    for ($i = 1; $i -le $totalHeartbeats; $i++) {
        $currentTime = Get-Date
        $elapsedSeconds = [math]::Round(($currentTime - $startTime).TotalSeconds, 0)
        
        # 发送回车键 - 核心防中断操作
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 心跳 #$i - 发送回车键防止中断..." -ForegroundColor Cyan -NoNewline
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Write-Host " ✅ 已发送" -ForegroundColor Green
        
        Write-Host "   已运行: $elapsedSeconds 秒 | 剩余: $($testDuration - $elapsedSeconds) 秒" -ForegroundColor Gray
        
        $heartbeatCount = $i
        
        # 如果不是最后一次心跳，等待间隔
        if ($i -lt $totalHeartbeats) {
            Write-Host "   等待 $heartbeatInterval 秒..." -ForegroundColor DarkGray
            Start-Sleep -Seconds $heartbeatInterval
        }
    }
} catch {
    Write-Host "❌ 测试过程中出现错误: $_" -ForegroundColor Red
} finally {
    $endTime = Get-Date
    $totalSeconds = [math]::Round(($endTime - $startTime).TotalSeconds, 0)
    
    Write-Host ""
    Write-Host "=== 测试结束 ===" -ForegroundColor Cyan
    Write-Host "开始时间: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor White
    Write-Host "结束时间: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor White
    Write-Host "总运行时间: $totalSeconds 秒" -ForegroundColor White
    Write-Host "成功发送心跳次数: $heartbeatCount 次" -ForegroundColor White
    Write-Host "平均间隔: $(if ($heartbeatCount -gt 0) { [math]::Round($totalSeconds / $heartbeatCount, 1) } else { 0 }) 秒" -ForegroundColor White
    
    if ($heartbeatCount -eq $totalHeartbeats) {
        Write-Host "✅ 测试完成: 所有心跳成功发送" -ForegroundColor Green
    } else {
        Write-Host "⚠️ 测试中断: 完成 $heartbeatCount/$totalHeartbeats 次心跳" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   防中断测试脚本结束" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan

# 保持窗口打开以便查看结果
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")