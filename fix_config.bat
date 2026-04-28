@echo off
echo ============================================
echo     Fixing OpenClaw Configuration
echo ============================================
echo.

echo Current configuration has invalid "storage" key
echo Creating valid configuration...
echo.

REM Backup old config
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    copy "F:\openclaw-data\.openclaw\openclaw.json" "F:\openclaw-data\.openclaw\openclaw.json.backup"
    echo Old config backed up
)

REM Create valid minimal config
(
    echo {
    echo   "meta": {
    echo     "lastTouchedVersion": "2026.3.14",
    echo     "lastTouchedAt": "2026-04-17T00:00:00.000Z"
    echo   },
    echo   "gateway": {
    echo     "host": "0.0.0.0",
    echo     "port": 3000
    echo   },
    echo   "plugins": {
    echo     "allow": []
    echo   }
    echo }
) > "F:\openclaw-data\.openclaw\openclaw.json"

echo New configuration created:
type "F:\openclaw-data\.openclaw\openclaw.json"
echo.

echo Testing with new configuration...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

C:\nodejs\node.exe openclaw.mjs gateway --log-level info
echo Exit code: %errorlevel%
echo.

if %errorlevel% equ 0 (
    echo ✅ Configuration fixed! OpenClaw started successfully.
) else (
    echo ❌ Still having issues. Trying doctor command...
    echo.
    C:\nodejs\node.exe openclaw.mjs doctor --fix
)

echo.
pause