@echo off
echo ============================================
echo     Diagnosing OpenClaw Exit Code 1
echo ============================================
echo.

echo [1] Testing basic OpenClaw (no data directory)
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs --version
echo Basic test exit code: %errorlevel%
echo.

echo [2] Testing with F drive data directory
echo Starting OpenClaw with F drive data...
echo NOTE: If you see "remote closed, exit code 1", wait for error details
echo.
C:\nodejs\node.exe openclaw.mjs --data-dir "F:\openclaw-data\.openclaw"
echo Exit code with F drive: %errorlevel%
echo.

echo [3] Testing with verbose logging
echo Starting with verbose mode...
C:\nodejs\node.exe openclaw.mjs --data-dir "F:\openclaw-data\.openclaw" --log-level debug 2>&1 | head -20
echo.

echo [4] Testing with different port
echo Testing with port 3001...
C:\nodejs\node.exe openclaw.mjs --data-dir "F:\openclaw-data\.openclaw" --gateway.port 3001 --log-level error
echo Exit code with port 3001: %errorlevel%
echo.

echo [5] Checking F drive configuration
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Configuration file exists
    echo First few lines of config:
    type "F:\openclaw-data\.openclaw\openclaw.json" | head -10
) else (
    echo ERROR: No configuration file found
)
echo.

echo ============================================
echo Diagnosis Complete
echo ============================================
echo.
echo Summary:
echo - Basic OpenClaw works (version shows)
echo - Problem occurs with F drive data directory
echo.
echo Most likely causes:
echo 1. F drive permissions (exFAT limitations)
echo 2. Configuration file error
echo 3. Port conflict (3000 already in use)
echo 4. Node.js module compatibility
echo.
echo Next steps:
echo 1. Check detailed error output above
echo 2. Try downloading latest OpenClaw to F drive
echo 3. Check if port 3000 is already in use
echo 4. Test with temporary data directory
pause