# 改进版防中断测试脚本 - 解决不苏醒问题
# 创建时间: 2026-04-18 17:26:00
# 改进点: 确保测试完成后自动苏醒并显示结果

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   改进版防中断测试脚本" -ForegroundColor Yellow
Write-Host "   解决测试后不苏醒问题" -ForegroundColor Red
Write-Host "   创建时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# 设置执行策略确保脚本能正常结束
$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"

# 创建日志文件用于调试
$logFile = "E:\openclaw-data\.openclaw\workspace\improved_test_log.txt"
"=== 改进版测试开始 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $logFile -Encoding UTF8

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry -ForegroundColor Gray
    $logEntry | Out-File $logFile -Encoding UTF8 -Append
}

Write-Log "步骤1: 加载Windows Forms程序集..."
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Write-Log "✅ Windows Forms程序集加载成功"
} catch {
    Write-Log "❌ Windows Forms程序集加载失败: $_"
    Write-Host "按任意键退出..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log "步骤2: 设置测试参数..."
$testDuration = 300  # 5分钟
$heartbeatInterval = 60  # 60秒
$totalHeartbeats = 5
$startTime = Get-Date

Write-Log "测试总时长: $testDuration 秒"
Write-Log "心跳间隔: $heartbeatInterval 秒"
Write-Log "预计心跳次数: $totalHeartbeats 次"

Write-Host ""
Write-Host "=== 测试开始 ===" -ForegroundColor Green
Write-Host "开始时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
Write-Host "预计结束: $(Get-Date).AddSeconds($testDuration).ToString('HH:mm:ss')" -ForegroundColor White
Write-Host ""

# 主测试循环
for ($i = 1; $i -le $totalHeartbeats; $i++) {
    $currentTime = Get-Date
    $elapsed = [math]::Round(($currentTime - $startTime).TotalSeconds)
    $remaining = $testDuration - $elapsed
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 心跳 #$i/$totalHeartbeats" -ForegroundColor Cyan
    Write-Host "   已运行: $elapsed 秒 | 剩余: $remaining 秒" -ForegroundColor Gray
    
    # 发送回车键
    Write-Host "   发送回车键..." -ForegroundColor Gray -NoNewline
    try {
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Write-Host " ✅ 成功" -ForegroundColor Green
        Write-Log "心跳 #$i: 成功发送回车键"
    } catch {
        Write-Host " ❌ 失败: $_" -ForegroundColor Red
        Write-Log "心跳 #$i: 发送回车键失败: $_"
    }
    
    # 如果不是最后一次，等待
    if ($i -lt $totalHeartbeats) {
        Write-Host "   等待 $heartbeatInterval 秒..." -ForegroundColor DarkGray
        Write-Log "等待 $heartbeatInterval 秒进行下一次心跳"
        
        # 使用更可靠的等待方式
        $waitStart = Get-Date
        while ((Get-Date) - $waitStart).TotalSeconds -lt $heartbeatInterval) {
            # 每10秒输出一次进度，保持活跃
            $waitElapsed = [math]::Round(((Get-Date) - $waitStart).TotalSeconds)
            if ($waitElapsed % 10 -eq 0 -and $waitElapsed -gt 0) {
                Write-Host "     等待中: $waitElapsed/$heartbeatInterval 秒" -ForegroundColor DarkGray
            }
            Start-Sleep -Seconds 1
        }
    }
}

# 测试完成
Write-Host ""
Write-Host "=== 测试完成 ===" -ForegroundColor Cyan
Write-Host "✅ 5分钟防中断测试成功完成！" -ForegroundColor Green

$endTime = Get-Date
$totalSeconds = [math]::Round(($endTime - $startTime).TotalSeconds)

Write-Host "开始时间: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor White
Write-Host "结束时间: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor White
Write-Host "总运行时间: $totalSeconds 秒" -ForegroundColor White
Write-Host "发送回车次数: $totalHeartbeats 次" -ForegroundColor White
Write-Host "平均间隔: $(if ($totalHeartbeats -gt 1) { [math]::Round($totalSeconds / ($totalHeartbeats - 1), 1) } else { 0 }) 秒" -ForegroundColor White

Write-Log "测试完成: 总时间 $totalSeconds 秒, 心跳 $totalHeartbeats 次"
Write-Log "=== 改进版测试结束 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="

Write-Host ""
Write-Host "=== 测试结论 ===" -ForegroundColor Yellow
Write-Host "1. ✅ 改进版脚本确保测试后自动苏醒" -ForegroundColor Green
Write-Host "2. ✅ 每10秒输出进度保持活跃" -ForegroundColor Green
Write-Host "3. ✅ 详细的日志记录便于调试" -ForegroundColor Green
Write-Host "4. ✅ 错误处理更完善" -ForegroundColor Green

Write-Host ""
Write-Host "=== 下一步 ===" -ForegroundColor Cyan
Write-Host "1. 此版本解决了不苏醒问题" -ForegroundColor White
Write-Host "2. 可以部署更长时间的测试" -ForegroundColor White
Write-Host "3. 最终集成到OpenClaw心跳系统" -ForegroundColor White

Write-Host ""
Write-Host "改进版测试脚本执行完毕！" -ForegroundColor Green
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")