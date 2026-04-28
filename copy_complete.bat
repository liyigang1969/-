@echo off
echo Copying OpenClaw to F drive as main system...

REM Copy program files
echo Copying program files...
xcopy "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\*" "F:\OpenClaw_Main\program" /E /I /H /Y /Q

REM Copy workspace if exists
if exist "E:\openclaw-data\.openclaw\workspace" (
    echo Copying workspace files...
    xcopy "E:\openclaw-data\.openclaw\workspace\*" "F:\OpenClaw_Main\workspace" /E /I /H /Y /Q
)

REM Copy configuration if exists
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo Copying configuration...
    copy "F:\openclaw-data\.openclaw\openclaw.json" "F:\OpenClaw_Main\data\openclaw.json" 2>nul
)

echo Copy completed!
pause