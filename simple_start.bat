@echo off
echo Starting OpenClaw...
echo.

REM Kill process on port 18789 if exists
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :18789 2^>nul') do (
    taskkill /PID %%p /F >nul 2>&1
)

REM Set environment
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

REM Start OpenClaw
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs gateway --port 3000

echo.
echo OpenClaw stopped.
pause