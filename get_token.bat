@echo off
echo ============================================
echo     Getting OpenClaw Gateway Token
echo ============================================
echo.

echo Method 1: Check existing configuration
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Current configuration:
    type "F:\openclaw-data\.openclaw\openclaw.json"
    echo.
    echo Looking for token in config...
    findstr /i "token" "F:\openclaw-data\.openclaw\openclaw.json"
) else (
    echo No configuration file found
)

echo.
echo Method 2: Generate new token
echo Generating new gateway token...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
set OPENCLAW_DATA=F:\openclaw-data\.openclaw

REM Create config with new token
(
echo {
echo   "gateway": {
echo     "mode": "local",
echo     "host": "0.0.0.0",
echo     "port": 3003,
echo     "auth": {
echo       "mode": "token",
echo       "token": "openclaw_token_%RANDOM%%RANDOM%%RANDOM%"
echo     }
echo   }
echo }
) > "F:\openclaw-data\.openclaw\openclaw_new.json"

echo New configuration with token created:
type "F:\openclaw-data\.openclaw\openclaw_new.json"

echo.
echo Method 3: Try dashboard command
echo Running dashboard command...
C:\nodejs\node.exe openclaw.mjs dashboard
echo.

echo IMPORTANT: If you see a token in the output above, copy it!
echo The token looks like a long random string.
echo.

pause