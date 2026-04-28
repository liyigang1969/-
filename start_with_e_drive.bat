@echo off
echo ============================================
echo     Starting OpenClaw with E Drive Data
echo ============================================
echo.

echo Using E drive data directory
echo Path: E:\openclaw-data\.openclaw
echo.

REM Set environment variables
set OPENCLAW_DATA=E:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=E:\openclaw-data\.openclaw

echo Environment variables set:
echo OPENCLAW_DATA=%OPENCLAW_DATA%
echo OPENCLAW_STATE_DIR=%OPENCLAW_STATE_DIR%
echo.

echo Starting OpenClaw Gateway...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs gateway

echo.
echo Exit code: %errorlevel%
echo.
pause