@echo off
REM This batch file won't flash because it starts a new window

echo Starting OpenClaw in new window...
echo.

start "OpenClaw Gateway" cmd /k "echo Starting OpenClaw... && echo. && set OPENCLAW_DATA=F:\openclaw-data\.openclaw && set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw && cd /d C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw && C:\nodejs\node.exe openclaw.mjs gateway --port 3003 --log-level info && pause"

echo.
echo A new window has opened with OpenClaw.
echo If you see a gateway token, copy it.
echo.
pause