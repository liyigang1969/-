# Docker fix v2 - English version to avoid encoding issues
Write-Host "=== Docker Fix v2 ===" -ForegroundColor Cyan

# Step 1: Kill residual Docker Desktop processes
Write-Host "[1/5] Cleaning processes..." -ForegroundColor Yellow
Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3
Write-Host "  OK"

# Step 2: Set service to auto-start
Write-Host "[2/5] Setting service to auto-start..." -ForegroundColor Yellow
Set-Service -Name "com.docker.service" -StartupType Automatic
Write-Host "  OK"

# Step 3: Start service
Write-Host "[3/5] Starting service..." -ForegroundColor Yellow
Start-Service -Name "com.docker.service" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
$svc = Get-Service com.docker.service
Write-Host "  Service: $($svc.Status)"

# Step 4: Launch Docker Desktop GUI
Write-Host "[4/5] Launching Docker Desktop..." -ForegroundColor Yellow
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
Write-Host "  OK"

# Step 5: Wait for Docker engine to be ready
Write-Host "[5/5] Waiting for Docker engine (up to 60s)..." -ForegroundColor Yellow
$dockerExe = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
$maxWait = 60
$elapsed = 0
$ready = $false
do {
    $result = & $dockerExe info 2>&1
    if ($result -match "Server Version") {
        $ready = $true
        Write-Host "  Docker engine ready! (${elapsed}s)" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 3
    $elapsed += 3
    if ($elapsed -ge $maxWait) {
        Write-Host "  Timeout after ${maxWait}s" -ForegroundColor Red
        break
    }
    Write-Host "  waiting ${elapsed}s..."
} while (-not $ready)

# Final check
Write-Host "" -NoNewline
Write-Host "=== Final Status ===" -ForegroundColor Cyan
Write-Host "Service: $( (Get-Service com.docker.service).Status )"
wsl -l -v 2>&1 | ForEach-Object { Write-Host "  $_" }
& $dockerExe ps 2>&1 | Select-Object -First 3

Write-Host "" -NoNewline
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "If tray icon is still black, wait 20-30 seconds or right-click tray icon -> Troubleshoot -> Restart"