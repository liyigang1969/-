@echo off
echo ============================================
echo     Starting OpenClaw - Final Attempt
echo ============================================
echo.

echo Method 1: Using environment variable
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs gateway
echo Exit code: %errorlevel%
echo.

echo Method 2: Using --profile parameter
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs --profile f-drive gateway
echo Exit code: %errorlevel%
echo.

echo Method 3: Check current configuration
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Configuration file content:
    type "F:\openclaw-data\.openclaw\openclaw.json"
) else (
    echo No configuration file found
)
echo.

echo Method 4: Try setup command
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs setup --data-dir "F:\openclaw-data\.openclaw"
echo Exit code: %errorlevel%
echo.

pause