# 简单的鼠标键盘自动化循环
# 安全、无害的自动化程序

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🖱️⌨️ 鼠标键盘自动化程序" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "这是一个安全的自动化循环程序"
Write-Host "模拟基本的用户操作"
Write-Host ""
Write-Host "按 Ctrl+C 停止程序" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$loopCount = 0

try {
    while ($true) {
        $loopCount++
        $currentTime = Get-Date -Format "HH:mm:ss"
        
        Write-Host "[$currentTime] 循环 #$loopCount 运行中..." -ForegroundColor Green
        
        # 显示当前操作
        Write-Host "   操作 1: 记录状态" -ForegroundColor Gray
        Write-Host "   操作 2: 模拟空闲" -ForegroundColor Gray
        Write-Host "   操作 3: 准备下一次循环" -ForegroundColor Gray
        
        # 这里可以添加实际的自动化操作
        # 例如：
        # 1. 移动鼠标
        # 2. 发送按键
        # 3. 点击等
        
        # 简单的模拟操作
        if ($loopCount % 5 -eq 0) {
            Write-Host "   🔄 每5次循环执行特殊操作..." -ForegroundColor Yellow
        }
        
        Write-Host ""
        
        # 等待5秒
        Start-Sleep -Seconds 5
    }
}
catch {
    Write-Host ""
    Write-Host "程序被中断" -ForegroundColor Red
    Write-Host "总循环次数: $loopCount" -ForegroundColor Yellow
    Write-Host "程序结束" -ForegroundColor Cyan
}