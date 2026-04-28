@echo off
echo ============================================
echo     One-Click OpenClaw Test
echo ============================================
echo.

echo This script will test OpenClaw and capture gateway token
echo.

echo Step 1: Check F drive OpenClaw directory
if not exist "F:\OpenClaw_Fresh" (
    echo Creating OpenClaw directory on F drive...
    mkdir "F:\OpenClaw_Fresh" 2>nul
    xcopy "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\*" "F:\OpenClaw_Fresh" /E /I /H /Y /Q
    echo ✅ Copied OpenClaw to F drive
) else (
    echo ✅ OpenClaw directory already exists on F drive
)
echo.

echo Step 2: Clean up old processes
echo Stopping any OpenClaw processes...
taskkill /F /IM node.exe 2>nul
echo.

echo Step 3: Set up fresh configuration
echo Creating clean configuration...
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    copy "F:\openclaw-data\.openclaw\openclaw.json" "F:\openclaw-data\.openclaw\openclaw.json.backup"
)
(
    echo {
    echo   "gateway": {
    echo     "mode": "local",
    echo     "host": "0.0.0.0",
    echo     "port": 3003
    echo   }
    echo }
) > "F:\openclaw-data\.openclaw\openclaw.json"
echo ✅ Fresh configuration created
echo.

echo Step 4: Start OpenClaw and capture output
echo Starting OpenClaw Gateway...
echo IMPORTANT: If you see a gateway token, copy it immediately!
echo.
echo The gateway will start on port 3003
echo Look for lines containing "token" or "auth"
echo.

set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

cd /d "F:\OpenClaw_Fresh"
C:\nodejs\node.exe openclaw.mjs gateway --port 3003 --log-level info

echo.
echo ============================================
echo Test Complete
echo ============================================
echo.
echo If you saw a gateway token:
echo 1. Copy the token (it looks like a long random string)
echo 2. Paste it here
echo 3. We'll configure OpenClaw with it
echo.
echo If no token appeared:
echo 1. OpenClaw may have started successfully
echo 2. Or there may be an error
echo 3. Check the output above for clues
echo.
pause