# PATH环境变量设置脚本
# 需要以管理员身份运行

Write-Host "=== Node.js PATH 设置工具 ===" -ForegroundColor Cyan
Write-Host "此脚本将添加 C:\nodejs 到系统PATH环境变量" -ForegroundColor Yellow
Write-Host ""

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "错误: 需要以管理员身份运行此脚本" -ForegroundColor Red
    Write-Host "请右键点击PowerShell，选择'以管理员身份运行'" -ForegroundColor Yellow
    Write-Host "或者使用以下命令: Start-Process PowerShell -Verb RunAs -ArgumentList '-File set_path.ps1'" -ForegroundColor Yellow
    pause
    exit 1
}

# 要添加的路径
$nodePath = "C:\nodejs"

# 检查路径是否存在
if (-not (Test-Path $nodePath)) {
    Write-Host "错误: Node.js目录不存在: $nodePath" -ForegroundColor Red
    Write-Host "请先安装Node.js" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Node.js目录存在: $nodePath" -ForegroundColor Green

# 获取当前系统PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
Write-Host "当前系统PATH长度: $($currentPath.Length) 字符" -ForegroundColor Gray

# 检查是否已包含该路径
if ($currentPath -like "*$nodePath*") {
    Write-Host "✅ PATH中已包含Node.js路径" -ForegroundColor Green
    Write-Host "无需更改" -ForegroundColor Gray
} else {
    Write-Host "正在添加Node.js路径到系统PATH..." -ForegroundColor Yellow
    
    # 添加新路径
    $newPath = $currentPath + ";" + $nodePath
    
    try {
        # 设置新的PATH
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "✅ PATH更新成功!" -ForegroundColor Green
        
        # 立即更新当前进程的PATH
        $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
        
    } catch {
        Write-Host "❌ PATH更新失败: $_" -ForegroundColor Red
        pause
        exit 1
    }
}

# 验证设置
Write-Host "`n=== 验证设置 ===" -ForegroundColor Cyan

# 检查node命令
$nodeCommand = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCommand) {
    Write-Host "✅ node命令可用: $($nodeCommand.Source)" -ForegroundColor Green
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "  版本: $nodeVersion" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  node命令不可用，可能需要重启命令行窗口" -ForegroundColor Yellow
}

# 检查npm命令
$npmCommand = Get-Command npm -ErrorAction SilentlyContinue
if ($npmCommand) {
    Write-Host "✅ npm命令可用: $($npmCommand.Source)" -ForegroundColor Green
    $npmVersion = npm --version 2>$null
    if ($npmVersion) {
        Write-Host "  版本: $npmVersion" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  npm命令不可用，可能需要重启命令行窗口" -ForegroundColor Yellow
}

# 测试OpenClaw
Write-Host "`n=== 测试OpenClaw ===" -ForegroundColor Cyan
$openclawDir = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
if (Test-Path $openclawDir) {
    Push-Location $openclawDir
    $openclawVersion = node openclaw.mjs --version 2>$null
    Pop-Location
    
    if ($openclawVersion) {
        Write-Host "✅ OpenClaw运行正常: $openclawVersion" -ForegroundColor Green
    } else {
        Write-Host "⚠️  OpenClaw运行测试失败" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ OpenClaw目录不存在" -ForegroundColor Red
}

Write-Host "`n=== 设置完成 ===" -ForegroundColor Cyan
Write-Host "注意事项:" -ForegroundColor Yellow
Write-Host "1. 可能需要重启已打开的命令行窗口" -ForegroundColor White
Write-Host "2. 新打开的窗口应该能直接使用node和npm命令" -ForegroundColor White
Write-Host "3. 测试命令: node --version" -ForegroundColor White
Write-Host "4. 测试命令: npm --version" -ForegroundColor White

Write-Host "`n✅ PATH设置完成!" -ForegroundColor Green
pause