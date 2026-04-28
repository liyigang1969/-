# check_system.ps1 - 检查系统环境和输入设备
Write-Host "=== 系统环境检查 ===" -ForegroundColor Cyan
Write-Host "开始时间: $(Get-Date -Format 'HH:mm:ss')"

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "✅ 当前以管理员身份运行" -ForegroundColor Green
} else {
    Write-Host "⚠️  当前不是管理员身份" -ForegroundColor Yellow
}

# 检查Python
Write-Host "`n=== Python检查 ===" -ForegroundColor Cyan
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python已安装: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python未安装或不在PATH中" -ForegroundColor Red
}

# 检查PowerShell版本
Write-Host "`n=== PowerShell检查 ===" -ForegroundColor Cyan
Write-Host "版本: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "编辑模式: $($Host.UI.RawUI.WindowTitle)" -ForegroundColor Gray

# 检查输入设备
Write-Host "`n=== 输入设备检查 ===" -ForegroundColor Cyan

# 键盘设备
$keyboardDevices = Get-PnpDevice -Class Keyboard -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "OK"}
Write-Host "键盘设备: $($keyboardDevices.Count) 个" -ForegroundColor Gray
if ($keyboardDevices.Count -gt 0) {
    Write-Host "  第一个键盘: $($keyboardDevices[0].FriendlyName)" -ForegroundColor Gray
}

# 鼠标设备
$mouseDevices = Get-PnpDevice -Class Mouse -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "OK"}
Write-Host "鼠标设备: $($mouseDevices.Count) 个" -ForegroundColor Gray
if ($mouseDevices.Count -gt 0) {
    Write-Host "  第一个鼠标: $($mouseDevices[0].FriendlyName)" -ForegroundColor Gray
}

# 测试SendInput功能
Write-Host "`n=== SendInput功能测试 ===" -ForegroundColor Cyan
Add-Type -AssemblyName System.Windows.Forms

try {
    # 获取当前鼠标位置
    $cursorPos = [System.Windows.Forms.Cursor]::Position
    Write-Host "✅ 当前鼠标位置: X=$($cursorPos.X), Y=$($cursorPos.Y)" -ForegroundColor Green
    
    # 测试键盘输入
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Write-Host "✅ SendInput键盘测试成功" -ForegroundColor Green
    
} catch {
    Write-Host "❌ 输入测试失败: $_" -ForegroundColor Red
}

# 总结
Write-Host "`n=== 检查完成 ===" -ForegroundColor Cyan
Write-Host "结束时间: $(Get-Date -Format 'HH:mm:ss')"

if ($keyboardDevices.Count -gt 0 -and $mouseDevices.Count -gt 0) {
    Write-Host "✅ 系统输入设备正常" -ForegroundColor Green
    Write-Host "可以开始心跳保持测试" -ForegroundColor Gray
} else {
    Write-Host "❌ 系统输入设备异常" -ForegroundColor Red
    Write-Host "请检查键盘鼠标连接" -ForegroundColor Yellow
}

Write-Host "`n下一步: 运行心跳保持测试" -ForegroundColor Cyan
Write-Host "命令: powershell -ExecutionPolicy Bypass -File heartbeat_test.ps1" -ForegroundColor Yellow