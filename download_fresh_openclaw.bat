@echo off
echo ============================================
echo     Download Fresh OpenClaw to F Drive
echo ============================================
echo.

set TARGET_DIR=F:\OpenClaw_Fresh
set ZIP_FILE=F:\openclaw_fresh.zip
set GITHUB_URL=https://github.com/openclaw/openclaw/archive/refs/heads/main.zip

echo Target directory: %TARGET_DIR%
echo Download URL: %GITHUB_URL%
echo.

echo Step 1: Clean up old directory
if exist "%TARGET_DIR%" (
    echo Removing old directory...
    rmdir /s /q "%TARGET_DIR%" 2>nul
)
mkdir "%TARGET_DIR%" 2>nul
echo.

echo Step 2: Download latest OpenClaw
echo Downloading... This may take a few minutes.
where powershell >nul 2>&1
if %errorlevel% equ 0 (
    echo Using PowerShell to download...
    powershell -Command "Invoke-WebRequest -Uri '%GITHUB_URL%' -OutFile '%ZIP_FILE%'"
) else (
    echo Using bitsadmin to download...
    bitsadmin /transfer openclawdownload /download /priority high "%GITHUB_URL%" "%ZIP_FILE%"
)

if not exist "%ZIP_FILE%" (
    echo ❌ Download failed
    echo Please manually download from: %GITHUB_URL%
    echo Save as: %ZIP_FILE%
    pause
    exit /b 1
)

echo ✅ Download complete
for %%F in ("%ZIP_FILE%") do (
    set /a SIZE=%%~zF/1048576
    echo File size: !SIZE! MB
)
echo.

echo Step 3: Extract files
echo Extracting to %TARGET_DIR%...
where tar >nul 2>&1
if %errorlevel% equ 0 (
    tar -xf "%ZIP_FILE%" -C "%TARGET_DIR%"
) else (
    powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TARGET_DIR%' -Force"
)

echo ✅ Extraction complete
echo.

echo Step 4: Organize directory
echo Organizing files...
for /d %%d in ("%TARGET_DIR%\openclaw-main*") do (
    set EXTRACTED_DIR=%%d
)

if defined EXTRACTED_DIR (
    echo Found extracted directory: !EXTRACTED_DIR!
    xcopy "!EXTRACTED_DIR!\*" "%TARGET_DIR%" /E /I /H /Y /Q
    rmdir /s /q "!EXTRACTED_DIR!" 2>nul
    echo Files organized
) else (
    echo ⚠️ Could not find extracted main directory
    dir "%TARGET_DIR%" /b
)
echo.

echo Step 5: Verify installation
echo Verifying OpenClaw files...
set MISSING=0

if exist "%TARGET_DIR%\openclaw.mjs" (
    echo ✅ openclaw.mjs exists
) else (
    echo ❌ openclaw.mjs missing
    set /a MISSING+=1
)

if exist "%TARGET_DIR%\package.json" (
    echo ✅ package.json exists
    for /f "tokens=2 delims=:," %%v in ('type "%TARGET_DIR%\package.json" ^| findstr "version"') do (
        set VERSION=%%v
    )
    echo Version: !VERSION!
) else (
    echo ❌ package.json missing
    set /a MISSING+=1
)

echo.
echo Step 6: Clean up
del "%ZIP_FILE%" 2>nul
echo Cleanup done
echo.

echo Step 7: Create test script
(
    echo @echo off
    echo echo Testing fresh OpenClaw installation
    echo echo.
    echo set OPENCLAW_DATA=F:\openclaw-data\.openclaw
    echo set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw
    echo.
    echo cd /d "%TARGET_DIR%"
    echo C:\nodejs\node.exe openclaw.mjs gateway --port 3001
    echo.
    echo echo If you see gateway token page, copy the token
    echo pause
) > "F:\test_fresh_openclaw.bat"

echo ✅ Test script created: F:\test_fresh_openclaw.bat
echo.

echo ============================================
if %MISSING% equ 0 (
    echo ✅ Fresh OpenClaw downloaded successfully!
    echo.
    echo Installation: %TARGET_DIR%
    echo Version: !VERSION!
    echo.
    echo To test:
    echo 1. Run: F:\test_fresh_openclaw.bat
    echo 2. If gateway token page appears, copy the token
    echo 3. Paste the token here for configuration
) else (
    echo ⚠️ Download completed with !MISSING! missing files
)
echo ============================================
pause