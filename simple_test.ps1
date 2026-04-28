# 最简单的防中断测试脚本
Write-Host "=== 最简单测试脚本 ===" -ForegroundColor Green
Write-Host "开始时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White

# 发送回车键
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Write-Host "? 回车键发送成功" -ForegroundColor Green

# 等待5秒
Write-Host "等待5秒..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# 再次发送回车键
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Write-Host "? 第二次回车键发送成功" -ForegroundColor Green

Write-Host "=== 测试完成 ===" -ForegroundColor Green
Write-Host "结束时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
