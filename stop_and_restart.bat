@echo off
echo ============================================
echo     Stop and Restart OpenClaw
echo ============================================
echo.

echo Step 1: Stop any running OpenClaw gateway
echo Checking for running gateway...
"C:\nodejs\node.exe" "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" gateway stop
echo.

echo Step 2: Kill process on port 18789
echo Killing process using port 18789...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :18789') do (
    echo Found process PID: %%p
    taskkill /PID %%p /F 2>nul
    if errorlevel 1 (
        echo Could not kill PID %%p
    ) else (
        echo Successfully killed PID %%p
    )
)
echo.

echo Step 3: Wait a moment
echo Waiting for processes to fully stop...
timeout /t 2 /nobreak >nul
echo.

echo Step 4: Start fresh gateway on port 3000
echo Starting OpenClaw Gateway on port 3000...
echo.
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

"C:\nodejs\node.exe" "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" gateway --port 3000 --log-level info

echo.
echo OpenClaw exited with code: %errorlevel%
if %errorlevel% equ 0 (
    echo ✅ SUCCESS! OpenClaw is running.
) else (
    echo ❌ OpenClaw failed to start.
)

echo.
pause