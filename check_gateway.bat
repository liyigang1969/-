@echo off
echo ============================================
echo     Checking OpenClaw Gateway Status
echo ============================================
echo.

echo Step 1: Check if port 3003 is in use
netstat -ano | findstr :3003
if errorlevel 1 (
    echo Port 3003 is not in use
) else (
    echo Port 3003 is in use - Gateway may be running
)

echo.
echo Step 2: Check gateway process
tasklist | findstr node
echo.

echo Step 3: Try to access gateway
echo Opening browser to check gateway...
start http://localhost:3003
start http://127.0.0.1:3003

echo.
echo Step 4: Check for gateway token
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Checking configuration for token...
    findstr "token" "F:\openclaw-data\.openclaw\openclaw.json"
) else (
    echo No configuration file found
)

echo.
echo Step 5: Get gateway info
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
C:\nodejs\node.exe openclaw.mjs gateway status 2>&1 | head -20

echo.
pause