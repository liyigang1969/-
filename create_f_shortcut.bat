@echo off
echo Creating F drive OpenClaw shortcut...

REM Create batch file on F drive
(
echo @echo off
echo echo OpenClaw F Drive ^(Main System^)
echo echo ================================
echo echo.
echo echo Data directory: F:\openclaw-data\.openclaw
echo echo Port: 3000
echo echo.
echo set OPENCLAW_DATA=F:\openclaw-data\.openclaw
echo set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw
echo.
echo echo Starting OpenClaw Gateway...
echo cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
echo C:\nodejs\node.exe openclaw.mjs gateway --port 3000 --log-level info
echo echo.
echo pause
) > "F:\OpenClaw_Main.bat"

echo Batch file created: F:\OpenClaw_Main.bat

REM Create desktop shortcut
(
echo Set WshShell = CreateObject("WScript.Shell")
echo desktop = WshShell.SpecialFolders("Desktop")
echo Set link = WshShell.CreateShortcut(desktop ^& "\OpenClaw F Drive.lnk")
echo link.TargetPath = "F:\OpenClaw_Main.bat"
echo link.WindowStyle = 1
echo link.IconLocation = "shell32.dll,21"
echo link.Description = "OpenClaw Main System on F Drive"
echo link.Save
echo WScript.Echo "Shortcut created on desktop"
) > "%TEMP%\shortcut.vbs"

cscript //nologo "%TEMP%\shortcut.vbs"
del "%TEMP%\shortcut.vbs"

echo.
echo ✅ F drive OpenClaw setup complete!
echo.
echo Files created:
echo 1. F:\OpenClaw_Main.bat - 启动脚本
echo 2. Desktop shortcut - "OpenClaw F Drive.lnk"
echo.
echo To start: Double-click desktop shortcut
echo.
pause