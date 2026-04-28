# OpenClaw PowerShell Launcher
# Run by right-clicking and selecting "Run with PowerShell"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "     OpenClaw PowerShell Launcher" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Test Node.js
Write-Host "1. Testing Node.js..." -ForegroundColor Yellow
if (Test-Path "C:\nodejs\node.exe") {
    $nodeVersion = & "C:\nodejs\node.exe" --version
    Write-Host "   ✅ Node.js version: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Node.js not found at C:\nodejs\node.exe" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Test F drive
Write-Host "2. Testing F drive..." -ForegroundColor Yellow
$dataDir = "F:\openclaw-data\.openclaw"
if (Test-Path $dataDir) {
    Write-Host "   ✅ F drive data directory exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ F drive data directory not found" -ForegroundColor Red
    Write-Host "   Creating directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

Write-Host ""

# Copy OpenClaw to F drive if needed
Write-Host "3. Preparing OpenClaw on F drive..." -ForegroundColor Yellow
$openclawDir = "F:\OpenClaw_Fresh"
$openclawPath = Join-Path $openclawDir "openclaw.mjs"

if (-not (Test-Path $openclawPath)) {
    Write-Host "   Copying OpenClaw to F drive..." -ForegroundColor Yellow
    $sourceDir = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
    
    if (Test-Path $sourceDir) {
        Copy-Item -Path "$sourceDir\*" -Destination $openclawDir -Recurse -Force
        Write-Host "   ✅ OpenClaw copied to F drive" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Source OpenClaw directory not found" -ForegroundColor Red
    }
} else {
    Write-Host "   ✅ OpenClaw already exists on F drive" -ForegroundColor Green
}

Write-Host ""

# Create clean configuration
Write-Host "4. Creating clean configuration..." -ForegroundColor Yellow
$configPath = "F:\openclaw-data\.openclaw\openclaw_clean.json"
$configContent = @"
{
  "gateway": {
    "mode": "local",
    "host": "0.0.0.0",
    "port": 3003
  }
}
"@

$configContent | Set-Content -Path $configPath -Encoding UTF8
Write-Host "   ✅ Clean configuration created" -ForegroundColor Green

Write-Host ""

# Start OpenClaw
Write-Host "5. Starting OpenClaw Gateway..." -ForegroundColor Cyan
Write-Host "   Port: 3003" -ForegroundColor Gray
Write-Host "   Data directory: $dataDir" -ForegroundColor Gray
Write-Host "   OpenClaw directory: $openclawDir" -ForegroundColor Gray
Write-Host ""
Write-Host "   IMPORTANT: If you see a gateway token, copy it!" -ForegroundColor Magenta
Write-Host "   The token looks like a long random string." -ForegroundColor Gray
Write-Host ""
Write-Host "   Press Ctrl+C to stop OpenClaw" -ForegroundColor Yellow
Write-Host ""

# Set environment variables
$env:OPENCLAW_DATA = $dataDir
$env:OPENCLAW_STATE_DIR = $dataDir
$env:OPENCLAW_CONFIG_PATH = $configPath

# Change to OpenClaw directory and start
Set-Location $openclawDir
& "C:\nodejs\node.exe" openclaw.mjs gateway --port 3003 --log-level info

Write-Host ""
Write-Host "OpenClaw has stopped." -ForegroundColor Cyan
Read-Host "Press Enter to exit"