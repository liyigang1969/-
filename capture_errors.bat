@echo off
echo ============================================
echo     Capturing OpenClaw Error Details
echo ============================================
echo.

echo Setting up error log...
set ERROR_LOG=E:\openclaw-data\.openclaw\workspace\openclaw_error.log
echo Error capture started: %date% %time% > "%ERROR_LOG%"
echo.

echo Method 1: Try with maximum logging
echo Testing with debug logging... >> "%ERROR_LOG%"
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
set OPENCLAW_DATA=F:\openclaw-data\.openclaw
set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw

echo Running: node openclaw.mjs gateway --log-level debug >> "%ERROR_LOG%"
C:\nodejs\node.exe openclaw.mjs gateway --log-level debug 2>&1 >> "%ERROR_LOG%"
echo Exit code: %errorlevel% >> "%ERROR_LOG%"
echo.
echo Debug log saved to: %ERROR_LOG%
echo.

echo Method 2: Try minimal configuration
echo Testing minimal setup... >> "%ERROR_LOG%"
echo --- New test --- >> "%ERROR_LOG%"

REM Create minimal config
if not exist "F:\openclaw-data\.openclaw\config_minimal.json" (
    echo Creating minimal config... >> "%ERROR_LOG%"
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   }
        echo }
    ) > "F:\openclaw-data\.openclaw\config_minimal.json"
)

set OPENCLAW_CONFIG_PATH=F:\openclaw-data\.openclaw\config_minimal.json
C:\nodejs\node.exe openclaw.mjs gateway --log-level error 2>&1 >> "%ERROR_LOG%"
echo Exit code with minimal config: %errorlevel% >> "%ERROR_LOG%"
echo.

echo Method 3: Check for common issues
echo Checking for common issues... >> "%ERROR_LOG%"
echo --- System check --- >> "%ERROR_LOG%"

REM Check Node.js version
C:\nodejs\node.exe --version >> "%ERROR_LOG%" 2>&1

REM Check directory permissions
dir "F:\openclaw-data\.openclaw" >> "%ERROR_LOG%" 2>&1

REM Check if port 3000 is in use
netstat -ano | findstr :3000 >> "%ERROR_LOG%" 2>&1

echo.
echo ============================================
echo Error details captured in: %ERROR_LOG%
echo.
echo Please check the log file for specific errors.
echo Common issues:
echo 1. Port 3000 already in use
echo 2. Missing dependencies
echo 3. Configuration errors
echo 4. Permission issues
echo ===========================================%
echo.
type "%ERROR_LOG%"
echo.
pause