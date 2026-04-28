@echo off
echo ============================================
echo     Universal OpenClaw Starter
echo ============================================
echo.

echo Checking available data directories...
echo.

REM Try F drive first
if exist "F:\openclaw-data\.openclaw" (
    echo ✅ F drive data directory available
    set DATA_DIR=F:\openclaw-data\.openclaw
    goto :start
)

REM Fall back to E drive
if exist "E:\openclaw-data\.openclaw" (
    echo ✅ E drive data directory available
    set DATA_DIR=E:\openclaw-data\.openclaw
    goto :start
)

REM Fall back to default location
echo ⚠️  No external data directory found
echo Using default location
set DATA_DIR=%USERPROFILE%\.openclaw
if not exist "%DATA_DIR%" (
    echo Creating default directory...
    mkdir "%DATA_DIR%" 2>nul
)

:start
echo.
echo Selected data directory: %DATA_DIR%
echo.

REM Set environment variables
set OPENCLAW_DATA=%DATA_DIR%
set OPENCLAW_STATE_DIR=%DATA_DIR%

echo Starting OpenClaw Gateway...
echo Note: Press Ctrl+C to stop
echo.

cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs gateway

echo.
echo OpenClaw has stopped
echo Exit code: %errorlevel%
echo.
pause