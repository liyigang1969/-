@echo off
echo OpenClaw Error Fix Tool
echo ========================
echo.

echo Step 1: Check Node.js
C:\nodejs\node.exe --version
if errorlevel 1 (
    echo ERROR: Node.js not found at C:\nodejs\node.exe
    pause
    exit /b 1
)

echo.
echo Step 2: Check F drive data directory
if not exist "F:\openclaw-data\.openclaw" (
    echo ERROR: Data directory not found
    pause
    exit /b 1
)
echo OK: Data directory exists

echo.
echo Step 3: Check configuration
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo OK: Configuration file exists
    findstr "dataDir.*F:/openclaw-data" "F:\openclaw-data\.openclaw\openclaw.json" >nul
    if errorlevel 1 (
        echo WARNING: Config may not point to F drive
    )
) else (
    echo WARNING: No configuration file
)

echo.
echo Step 4: Test basic OpenClaw
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs --version
if errorlevel 1 (
    echo ERROR: Basic OpenClaw test failed
) else (
    echo OK: Basic test passed
)

echo.
echo Step 5: Try to start with F drive data
echo Starting OpenClaw with F drive data...
echo If you see "remote closed, exit code 1", note the error details
echo.
C:\nodejs\node.exe openclaw.mjs --data-dir "F:\openclaw-data\.openclaw"

echo.
echo ========================
echo Fix tool completed
echo.
echo If error persists, try:
echo 1. Download latest OpenClaw to F drive
echo 2. Check F drive for errors
echo 3. Update Node.js to latest version
pause