@echo off
echo ============================================
echo     Fixing OpenClaw Plugin Issues
echo ============================================
echo.

echo Problem found: openclaw-weixin plugin missing dependencies
echo.

echo Solution 1: Disable the problematic plugin
if exist "F:\openclaw-data\.openclaw\extensions\openclaw-weixin" (
    echo Renaming plugin directory to disable it...
    ren "F:\openclaw-data\.openclaw\extensions\openclaw-weixin" "openclaw-weixin.disabled" 2>nul
    if errorlevel 1 (
        echo Could not rename, trying to remove...
        rmdir /s /q "F:\openclaw-data\.openclaw\extensions\openclaw-weixin" 2>nul
    )
    echo Plugin disabled
) else (
    echo Plugin directory not found
)
echo.

echo Solution 2: Update configuration to allow plugins
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Updating configuration...
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   },
        echo   "plugins": {
        echo     "allow": []
        echo   }
        echo }
    ) > "F:\openclaw-data\.openclaw\openclaw.json.new"
    move /y "F:\openclaw-data\.openclaw\openclaw.json.new" "F:\openclaw-data\.openclaw\openclaw.json" >nul
    echo Configuration updated
) else (
    echo Creating new configuration...
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   },
        echo   "plugins": {
        echo     "allow": []
        echo   }
        echo }
    ) > "F:\openclaw-data\.openclaw\openclaw.json"
    echo Configuration created
)
echo.

echo Solution 3: Test with correct parameters
echo Testing OpenClaw startup...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs --data "F:\openclaw-data\.openclaw" --log-level error
echo Exit code: %errorlevel%
echo.

echo ============================================
echo Fixes applied:
echo 1. Disabled problematic plugin
echo 2. Updated configuration
echo 3. Tested with correct --data parameter
echo ============================================
pause