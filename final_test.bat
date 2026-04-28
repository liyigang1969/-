@echo off
echo Final OpenClaw Test
echo ====================
echo.

echo Step 1: Check configuration
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Configuration exists
    type "F:\openclaw-data\.openclaw\openclaw.json"
) else (
    echo No configuration - creating default
    echo {} > "F:\openclaw-data\.openclaw\openclaw.json"
)

echo.
echo Step 2: Set environment variables
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw
echo OPENCLAW_DATA=%OPENCLAW_DATA%
echo OPENCLAW_STATE_DIR=%OPENCLAW_STATE_DIR%

echo.
echo Step 3: Run OpenClaw doctor
echo Running doctor to fix any issues...
"C:\nodejs\node.exe" "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" doctor --fix
echo Doctor exit code: %errorlevel%

echo.
echo Step 4: Try to start gateway
echo Starting OpenClaw Gateway...
echo If successful, it will keep running
echo If failed, you'll see error details
echo.
"C:\nodejs\node.exe" "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" gateway --log-level debug

echo.
echo OpenClaw exited with code: %errorlevel%
pause