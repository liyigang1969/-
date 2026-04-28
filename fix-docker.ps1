# ==============================================
# 🏢 Docker一键修复脚本
# 管理员身份运行本脚本
# ==============================================

Write-Host "📦 Docker 修复脚本" -ForegroundColor Cyan
Write-Host "================================"

# 1️⃣ 启动WSL
Write-Host "`n[1/4] 启动WSL..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 2
wsl -d docker-desktop --exec /bin/true 2>$null
wsl -d Ubuntu --exec /bin/true 2>$null
Write-Host "  ✅ WSL已启动"

# 2️⃣ 启动Docker服务
Write-Host "`n[2/4] 启动Docker服务..." -ForegroundColor Yellow
Start-Service -Name "com.docker.service" -ErrorAction Stop
Write-Host "  ✅ Docker服务已启动"

# 3️⃣ 启动Docker Desktop
Write-Host "`n[3/4] 启动Docker Desktop..." -ForegroundColor Yellow
$ddProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $ddProcess) {
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Write-Host "  ✅ Docker Desktop已启动"
} else {
    Write-Host "  ⏳ Docker Desktop已在运行中"
}

# 4️⃣ 等待Docker daemon就绪
Write-Host "`n[4/4] 等待Docker daemon就绪..." -ForegroundColor Yellow
$maxWait = 60  # 最多等60秒
$waitCount = 0
do {
    Start-Sleep -Seconds 3
    $waitCount += 3
    $result = & "C:\Program Files\Docker\Docker\resources\bin\docker.exe" info 2>&1
    $ready = $result -match "Server Version"
    if ($ready) {
        Write-Host "  ✅ Docker daemon就绪！(耗时${waitCount}秒)" -ForegroundColor Green
    } elseif ($waitCount -ge $maxWait) {
        Write-Host "  ⚠️ 超时${maxWait}秒，Docker仍未就绪" -ForegroundColor Red
        break
    } else {
        Write-Host "  ⏳ 等待中...(${waitCount}s)"
    }
} while (-not $ready)

# 验证
Write-Host "`n================================"
Write-Host "📋 最终状态检查" -ForegroundColor Cyan
$svc = Get-Service -Name "com.docker.service"
Write-Host "  Docker服务: $($svc.Status)"
wsl -l -v --all 2>&1 | ForEach-Object { Write-Host "  $_" }
Write-Host "`n✅ 完成！" -ForegroundColor Green
