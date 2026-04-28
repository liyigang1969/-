@echo off
echo ============================================
echo     Starting OpenClaw (Correct Parameters)
echo ============================================
echo.

echo Using correct parameters...
echo Data directory: F:\openclaw-data\.openclaw
echo.

cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"

echo Method 1: Using --data parameter
C:\nodejs\node.exe openclaw.mjs --data "F:\openclaw-data\.openclaw"
echo Exit code: %errorlevel%
echo.

echo Method 2: Using environment variable
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
C:\nodejs\node.exe openclaw.mjs
echo Exit code: %errorlevel%
echo.

echo Method 3: Check help for correct parameters
C:\nodejs\node.exe openclaw.mjs --help | findstr "data"
echo.

pause