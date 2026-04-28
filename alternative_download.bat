@echo off
echo ============================================
echo     Alternative OpenClaw Download
echo ============================================
echo.

echo If GitHub download fails, try these alternatives:
echo.
echo Option 1: Use npm to install (if network allows)
echo   cd /d F:\
echo   npm init -y
echo   npm install openclaw
echo.
echo Option 2: Manual download steps:
echo   1. Open browser to: https://github.com/openclaw/openclaw
echo   2. Click "Code" button (green)
echo   3. Click "Download ZIP"
echo   4. Save to: F:\openclaw-main.zip
echo   5. Extract to: F:\OpenClaw_Fresh
echo.
echo Option 3: Use current installation as base
echo   Copy from: C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw
echo   Copy to: F:\OpenClaw_Fresh
echo.

echo Creating copy script...
xcopy "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\*" "F:\OpenClaw_Fresh" /E /I /H /Y /Q
echo ✅ Copied current OpenClaw to F:\OpenClaw_Fresh
echo.

echo Creating test script...
(
    echo @echo off
    echo echo Testing copied OpenClaw
    echo echo.
    echo set OPENCLAW_DATA=F:\openclaw-data\.openclaw
    echo set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw
    echo.
    echo cd /d "F:\OpenClaw_Fresh"
    echo C:\nodejs\node.exe openclaw.mjs gateway --port 3002 --log-level info
    echo.
    echo echo Note: If gateway asks for token, copy it
    echo pause
) > "F:\test_copied_openclaw.bat"

echo ✅ Test script: F:\test_copied_openclaw.bat
echo.
echo To test copied version:
echo 1. Run: F:\test_copied_openclaw.bat
echo 2. Watch for gateway token
echo 3. Copy token if appears
echo.
pause