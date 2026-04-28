# test_interception_install.ps1 - Interception驱动安装测试
Write-Host "=== Interception驱动安装测试 ===" -ForegroundColor Cyan
Write-Host "开始时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Yellow

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ 需要管理员权限运行此脚本" -ForegroundColor Red
    Write-Host "请以管理员身份运行PowerShell，然后重新执行" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 当前以管理员身份运行" -ForegroundColor Green

# 检查Interception驱动是否已安装
Write-Host "`n1. 检查Interception驱动状态..." -ForegroundColor Cyan

$driverPath = "C:\Windows\System32\drivers\interception.sys"
if (Test-Path $driverPath) {
    Write-Host "✅ Interception驱动已安装: $driverPath" -ForegroundColor Green
    $driverInfo = Get-Item $driverPath
    Write-Host "   文件大小: $($driverInfo.Length) 字节" -ForegroundColor Gray
    Write-Host "   创建时间: $($driverInfo.CreationTime)" -ForegroundColor Gray
    Write-Host "   修改时间: $($driverInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "❌ Interception驱动未安装" -ForegroundColor Red
    Write-Host "   需要从GitHub下载并安装驱动" -ForegroundColor Yellow
}

# 检查Interception注册表项
Write-Host "`n2. 检查Interception注册表配置..." -ForegroundColor Cyan

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\interception"
if (Test-Path $regPath) {
    Write-Host "✅ Interception服务注册表项存在" -ForegroundColor Green
    $regValues = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    if ($regValues) {
        Write-Host "   显示名称: $($regValues.DisplayName)" -ForegroundColor Gray
        Write-Host "   启动类型: $($regValues.Start)" -ForegroundColor Gray
        Write-Host "   服务类型: $($regValues.Type)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Interception服务注册表项不存在" -ForegroundColor Red
}

# 检查Interception服务状态
Write-Host "`n3. 检查Interception服务状态..." -ForegroundColor Cyan

$service = Get-Service -Name "interception" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "✅ Interception服务已安装" -ForegroundColor Green
    Write-Host "   服务名称: $($service.Name)" -ForegroundColor Gray
    Write-Host "   显示名称: $($service.DisplayName)" -ForegroundColor Gray
    Write-Host "   状态: $($service.Status)" -ForegroundColor Gray
    Write-Host "   启动类型: $($service.StartType)" -ForegroundColor Gray
    
    if ($service.Status -ne "Running") {
        Write-Host "⚠️  Interception服务未运行，尝试启动..." -ForegroundColor Yellow
        try {
            Start-Service -Name "interception" -ErrorAction Stop
            Write-Host "✅ 服务启动成功" -ForegroundColor Green
        } catch {
            Write-Host "❌ 服务启动失败: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ Interception服务未安装" -ForegroundColor Red
}

# 检查系统输入设备
Write-Host "`n4. 检查系统输入设备..." -ForegroundColor Cyan

$keyboardDevices = Get-PnpDevice -Class Keyboard -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "OK"}
$mouseDevices = Get-PnpDevice -Class Mouse -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "OK"}

Write-Host "✅ 键盘设备: $($keyboardDevices.Count) 个" -ForegroundColor Green
Write-Host "✅ 鼠标设备: $($mouseDevices.Count) 个" -ForegroundColor Green

if ($keyboardDevices.Count -gt 0) {
    Write-Host "   第一个键盘: $($keyboardDevices[0].FriendlyName)" -ForegroundColor Gray
}
if ($mouseDevices.Count -gt 0) {
    Write-Host "   第一个鼠标: $($mouseDevices[0].FriendlyName)" -ForegroundColor Gray
}

# 测试系统输入功能
Write-Host "`n5. 测试系统输入功能..." -ForegroundColor Cyan

Write-Host "   测试SendInput API..." -ForegroundColor Gray
Add-Type -AssemblyName System.Windows.Forms

try {
    # 测试键盘输入
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Write-Host "   ✅ SendInput键盘测试成功" -ForegroundColor Green
    
    # 测试鼠标位置获取
    $cursorPos = [System.Windows.Forms.Cursor]::Position
    Write-Host "   ✅ 鼠标位置: X=$($cursorPos.X), Y=$($cursorPos.Y)" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ 输入测试失败: $_" -ForegroundColor Red
}

# 总结
Write-Host "`n=== 测试总结 ===" -ForegroundColor Cyan
Write-Host "结束时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Yellow

if ($service -and $service.Status -eq "Running") {
    Write-Host "✅ Interception驱动状态: 正常" -ForegroundColor Green
    Write-Host "   可以继续进行心跳保持测试" -ForegroundColor Gray
} else {
    Write-Host "❌ Interception驱动状态: 异常" -ForegroundColor Red
    Write-Host "   需要先安装Interception驱动" -ForegroundColor Yellow
    Write-Host "   下载地址: https://github.com/oblitum/Interception" -ForegroundColor Gray
}

Write-Host "`n下一步: 运行心跳保持测试脚本" -ForegroundColor Cyan
Write-Host "命令: .\heartbeat_keeper.ps1" -ForegroundColor Yellow