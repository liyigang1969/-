Write-Host "=== OpenClaw PowerShell调试工具 ===" -ForegroundColor Cyan
Write-Host ""

# 测试Node.js
Write-Host "[1] 检查Node.js..." -ForegroundColor Yellow
if (Test-Path "C:\nodejs\node.exe") {
    Write-Host "✅ Node.js存在" -ForegroundColor Green
    $nodeVersion = & "C:\nodejs\node.exe" --version
    Write-Host "   版本: $nodeVersion" -ForegroundColor Gray
} else {
    Write-Host "❌ Node.js不存在" -ForegroundColor Red
    Read-Host "按回车继续"
    exit 1
}

Write-Host ""

# 检查F盘目录
Write-Host "[2] 检查F盘数据目录..." -ForegroundColor Yellow
if (Test-Path "F:\openclaw-data\.openclaw") {
    Write-Host "✅ F盘数据目录存在" -ForegroundColor Green
    $dirInfo = Get-ChildItem "F:\openclaw-data\.openclaw" | Select-Object -First 5
    Write-Host "   目录内容:" -ForegroundColor Gray
    $dirInfo | ForEach-Object { Write-Host "   - $($_.Name)" }
} else {
    Write-Host "❌ F盘数据目录不存在" -ForegroundColor Red
}

Write-Host ""

# 检查OpenClaw程序
Write-Host "[3] 检查OpenClaw程序..." -ForegroundColor Yellow
$openclawPath = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs"
if (Test-Path $openclawPath) {
    Write-Host "✅ OpenClaw程序存在" -ForegroundColor Green
} else {
    Write-Host "❌ OpenClaw程序不存在" -ForegroundColor Red
}

Write-Host ""

# 尝试启动
Write-Host "[4] 尝试启动OpenClaw..." -ForegroundColor Yellow
Write-Host "注意: 如果出现错误，请记录错误信息" -ForegroundColor Magenta
Write-Host ""

Set-Location "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
& "C:\nodejs\node.exe" openclaw.mjs --data-dir "F:\openclaw-data\.openclaw"

Write-Host ""
Write-Host "调试完成！" -ForegroundColor Cyan
Read-Host "按回车退出"