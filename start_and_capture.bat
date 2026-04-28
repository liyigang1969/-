@echo off
echo ============================================
echo     Start OpenClaw and Capture Output
echo ============================================
echo.

echo Killing any existing OpenClaw processes...
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul

echo.
echo Setting up environment...
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

echo OPENCLAW_DATA=%OPENCLAW_DATA%
echo OPENCLAW_STATE_DIR=%OPENCLAW_STATE_DIR%
echo.

echo Creating clean configuration...
(
echo {
echo   "gateway": {
echo     "mode": "local",
echo     "host": "0.0.0.0",
echo     "port": 3000,
echo     "auth": {
echo       "mode": "token",
echo       "token": "test_token_%RANDOM%%RANDOM%_%RANDOM%"
echo     }
echo   },
echo   "plugins": {
echo     "allow": []
echo   }
echo }
) > "F:\openclaw-data\.openclaw\openclaw_clean.json"

echo Configuration saved to: F:\openclaw-data\.openclaw\openclaw_clean.json
echo.

echo Starting OpenClaw Gateway...
echo IMPORTANT: Watch for these things:
echo 1. Gateway token (long random string)
echo 2. "Listening on" message
echo 3. Any error messages
echo.
echo The window will stay open. Press Ctrl+C to stop.
echo.

cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs gateway --port 3000 --log-level info

echo.
echo OpenClaw has stopped.
echo Exit code: %errorlevel%
echo.
pause