@echo off
echo OpenClaw Test Script
echo.
echo Step 1: Check Node.js
C:\nodejs\node.exe --version
if errorlevel 1 echo ERROR: Node.js test failed
echo.
echo Step 2: Check F drive
dir F:\openclaw-data\.openclaw
if errorlevel 1 echo ERROR: F drive access failed
echo.
echo Step 3: Test OpenClaw
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs --version
if errorlevel 1 echo ERROR: OpenClaw test failed
echo.
echo Test complete!
pause