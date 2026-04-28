@echo off
echo Testing OpenClaw on different ports
echo ===================================
echo.

set OPENCLAW_DATA=F:\openclaw-data\.openclaw
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"

echo Trying port 3001...
start "OpenClaw 3001" cmd /k "echo Port 3001 && C:\nodejs\node.exe openclaw.mjs gateway --port 3001 --log-level error && pause"

timeout /t 3 /nobreak >nul

echo Trying port 3002...
start "OpenClaw 3002" cmd /k "echo Port 3002 && C:\nodejs\node.exe openclaw.mjs gateway --port 3002 --log-level error && pause"

timeout /t 3 /nobreak >nul

echo Trying port 3003...
start "OpenClaw 3003" cmd /k "echo Port 3003 && C:\nodejs\node.exe openclaw.mjs gateway --port 3003 --log-level error && pause"

echo.
echo Three windows have opened on ports 3001, 3002, 3003.
echo Check each window for:
echo 1. Success message
echo 2. Gateway token
echo 3. Error messages
echo.
echo The first successful one will stay running.
echo Close the failed ones.
echo.
pause