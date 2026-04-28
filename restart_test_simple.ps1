# 简单的OpenClaw重启测试脚本
Write-Host "=== OpenClaw重启测试开始 ===" -ForegroundColor Cyan

# 1. 检查当前进程
Write-Host "1. 检查当前OpenClaw进程..." -ForegroundColor Green
$processes = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "   找到 $($processes.Count) 个进程" -ForegroundColor Green
    foreach ($p in $processes) {
        Write-Host "   PID $($p.Id): $($p.ProcessName)" -ForegroundColor Gray
    }
} else {
    Write-Host "   未找到进程" -ForegroundColor Yellow
}

# 2. 停止进程
Write-Host "2. 停止OpenClaw进程..." -ForegroundColor Green
if ($processes) {
    $processes | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "   进程已停止" -ForegroundColor Green
}

# 3. 等待
Write-Host "3. 等待3秒..." -ForegroundColor Green
Start-Sleep -Seconds 3

# 4. 查找OpenClaw
Write-Host "4. 查找OpenClaw安装..." -ForegroundColor Green
$installDir = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
if (Test-Path $installDir) {
    Write-Host "   安装目录存在: $installDir" -ForegroundColor Green
    
    # 查找可能的启动方式
    $nodePath = Join-Path $installDir "node_modules\.bin\node"
    $mainJs = Join-Path $installDir "dist\main.js"
    
    if (Test-Path $mainJs) {
        Write-Host "   找到主文件: $mainJs" -ForegroundColor Green
        
        # 尝试通过node启动
        if (Test-Path $nodePath) {
            Write-Host "5. 通过Node.js启动OpenClaw..." -ForegroundColor Green
            Start-Process -FilePath $nodePath -ArgumentList $mainJs -WindowStyle Hidden -PassThru
            Write-Host "   启动命令已执行" -ForegroundColor Green
        } else {
            # 使用系统node
            Write-Host "5. 通过系统Node.js启动OpenClaw..." -ForegroundColor Green
            Start-Process -FilePath "node" -ArgumentList $mainJs -WindowStyle Hidden -PassThru
            Write-Host "   启动命令已执行" -ForegroundColor Green
        }
    } else {
        Write-Host "   ❌ 未找到主文件" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ 安装目录不存在" -ForegroundColor Red
}

# 5. 等待启动
Write-Host "6. 等待10秒让OpenClaw启动..." -ForegroundColor Green
Start-Sleep -Seconds 10

# 6. 验证
Write-Host "7. 验证启动结果..." -ForegroundColor Green
$newProcesses = Get-Process -Name "OpenClaw*" -ErrorAction SilentlyContinue
if ($newProcesses) {
    Write-Host "   ✅ 成功启动: $($newProcesses.Count) 个进程" -ForegroundColor Green
    foreach ($p in $newProcesses) {
        Write-Host "   PID $($p.Id): $($p.ProcessName)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ❌ 启动失败，未找到进程" -ForegroundColor Red
}

Write-Host "=== 重启测试完成 ===" -ForegroundColor Cyan
Write-Host "等待60秒后验证自动工作能力..." -ForegroundColor Yellow
Start-Sleep -Seconds 60