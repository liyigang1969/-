# 唤醒脚本 - 强制结束测试进程
Write-Host "=== 强制结束防中断测试 ===" -ForegroundColor Red
Write-Host "时间: 17:26:25" -ForegroundColor Yellow

# 结束测试进程
$testPid = 18960
if (Get-Process -Id $testPid -ErrorAction SilentlyContinue) {
    Write-Host "正在结束进程 PID: $testPid..." -ForegroundColor Yellow
    Stop-Process -Id $testPid -Force
    Write-Host "? 进程已结束" -ForegroundColor Green
} else {
    Write-Host "? 进程未找到: $testPid" -ForegroundColor Red
}

# 清理
if (Test-Path "E:\openclaw-data\.openclaw\workspace\test_log.txt") {
    Remove-Item "E:\openclaw-data\.openclaw\workspace\test_log.txt" -Force
    Write-Host "? 清理日志文件" -ForegroundColor Green
}

Write-Host "
=== 准备重新测试 ===" -ForegroundColor Cyan
Write-Host "1. 测试进程已清理" -ForegroundColor White
Write-Host "2. 可以开始新的测试" -ForegroundColor White
Write-Host "3. 按任意键继续..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
