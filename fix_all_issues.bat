@echo off
echo ============================================
echo     Fixing All OpenClaw Issues
echo ============================================
echo.

echo Issue 1: Fix configuration
echo Removing invalid "storage" key...
(
    echo {
    echo   "meta": {
    echo     "lastTouchedVersion": "2026.3.14",
    echo     "lastTouchedAt": "2026-04-17T00:00:00.000Z"
    echo   },
    echo   "gateway": {
    echo     "mode": "local",
    echo     "host": "0.0.0.0",
    echo     "port": 3000,
    echo     "auth": {
    echo       "mode": "token",
    echo       "token": "test_token_12345"
    echo     }
    echo   },
    echo   "plugins": {
    echo     "allow": []
    echo   },
    echo   "agents": {
    echo     "defaults": {
    echo       "memorySearch": {
    echo         "enabled": false
    echo       }
    echo     }
    echo   }
    echo }
) > "F:\openclaw-data\.openclaw\openclaw.json"

echo Configuration fixed.
echo.

echo Issue 2: Kill process using port 18789
echo Checking port 18789...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :18789') do (
    echo Killing process PID: %%p
    taskkill /PID %%p /F 2>nul
)
echo.

echo Issue 3: Set environment variables
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw
echo Environment variables set.
echo.

echo Issue 4: Run configure command
echo Running OpenClaw configure...
"C:\nodejs\node.exe" "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" config set gateway.mode local
echo.

echo Issue 5: Test startup
echo Testing OpenClaw startup...
echo If successful, OpenClaw will start and show listening on port 3000
echo.
"C:\nodejs\node.exe" "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" gateway --log-level info

echo.
echo OpenClaw exited with code: %errorlevel%
if %errorlevel% equ 0 (
    echo ✅ SUCCESS! OpenClaw is working!
) else (
    echo ❌ Still having issues. Check error above.
)

echo.
pause