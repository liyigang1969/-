Write-Host "OpenClaw PowerShell Test"
Write-Host ""

# Test Node.js
Write-Host "1. Testing Node.js..." -ForegroundColor Yellow
if (Test-Path "C:\nodejs\node.exe") {
    $version = & "C:\nodejs\node.exe" --version
    Write-Host "   Node.js version: $version" -ForegroundColor Green
} else {
    Write-Host "   ERROR: Node.js not found" -ForegroundColor Red
}

Write-Host ""

# Test F drive
Write-Host "2. Testing F drive..." -ForegroundColor Yellow
if (Test-Path "F:\openclaw-data\.openclaw") {
    Write-Host "   F drive data directory exists" -ForegroundColor Green
} else {
    Write-Host "   ERROR: F drive data directory not found" -ForegroundColor Red
}

Write-Host ""

# Test OpenClaw
Write-Host "3. Testing OpenClaw..." -ForegroundColor Yellow
$openclawPath = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs"
if (Test-Path $openclawPath) {
    Set-Location "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
    $result = & "C:\nodejs\node.exe" openclaw.mjs --version
    Write-Host "   OpenClaw version: $result" -ForegroundColor Green
} else {
    Write-Host "   ERROR: OpenClaw not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test complete!" -ForegroundColor Cyan
Read-Host "Press Enter to exit"