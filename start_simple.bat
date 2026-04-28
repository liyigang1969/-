@echo off
echo Simple OpenClaw Starter
echo =======================
echo.

echo Step 1: Clean up
taskkill /F /IM node.exe 2>nul

echo.
echo Step 2: Start OpenClaw
echo Starting on port 3000...
echo.

REM Start in a new window that won't close
start "OpenClaw Gateway" cmd /k "echo === OpenClaw Gateway === && echo. && set OPENCLAW_DATA=F:\openclaw-data\.openclaw && cd /d C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw && C:\nodejs\node.exe openclaw.mjs gateway --port 3000 && pause"

echo.
echo A new window has opened.
echo Please check the new window for:
echo 1. Gateway token
echo 2. Error messages
echo 3. "Listening on" message
echo.
echo If you see a token, copy it and paste here.
echo.
pause