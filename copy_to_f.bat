@echo off
echo ============================================
echo     Copy OpenClaw to F Drive
echo ============================================
echo.

set SOURCE=C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw
set TARGET=F:\OpenClaw_System\program

echo Source: %SOURCE%
echo Target: %TARGET%
echo.

echo Copying OpenClaw files...
xcopy "%SOURCE%\*" "%TARGET%" /E /I /H /Y /Q
echo Copy completed
echo.

echo Verifying copy...
if exist "%TARGET%\openclaw.mjs" (
    echo ✅ openclaw.mjs copied successfully
) else (
    echo ❌ openclaw.mjs missing
)

if exist "%TARGET%\package.json" (
    echo ✅ package.json copied successfully
) else (
    echo ❌ package.json missing
)

echo.
echo Creating data directory link...
if not exist "F:\OpenClaw_System\data\.openclaw" (
    if exist "F:\openclaw-data\.openclaw" (
        echo Linking to existing F drive data...
        mklink /J "F:\OpenClaw_System\data\.openclaw" "F:\openclaw-data\.openclaw" 2>nul
        if errorlevel 1 (
            echo Creating new data directory...
            mkdir "F:\OpenClaw_System\data\.openclaw" 2>nul
        )
    ) else (
        echo Creating new data directory...
        mkdir "F:\OpenClaw_System\data\.openclaw" 2>nul
    )
)

echo.
echo F drive OpenClaw setup complete!
echo Program: F:\OpenClaw_System\program
echo Data: F:\OpenClaw_System\data\.openclaw
echo.
pause