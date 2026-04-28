@echo off
echo Direct Error Test - Output will stay on screen
echo.

cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

echo Starting OpenClaw with error output visible...
echo.
C:\nodejs\node.exe openclaw.mjs gateway --log-level debug

echo.
echo OpenClaw exited with code: %errorlevel%
pause