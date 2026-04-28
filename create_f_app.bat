REM Create OpenClaw application on F drive
echo Creating OpenClaw application...

REM Copy OpenClaw files to F drive
echo Copying OpenClaw program files...
xcopy "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\*" "F:\OpenClaw_App\bin" /E /I /H /Y /Q

REM Create main launcher
echo Creating main launcher...
(
echo @echo off
echo echo ============================================
echo echo     OpenClaw Application (F Drive)
echo echo ============================================
echo echo.
echo echo F Drive now occupies the E drive position
echo echo Mouse interface restored
echo echo.
echo echo Starting OpenClaw Gateway...
echo echo.
echo set OPENCLAW_DATA=F:\OpenClaw_App\data
echo set OPENCLAW_STATE_DIR=F:\OpenClaw_App\data
echo.
echo cd /d "F:\OpenClaw_App\bin"
echo C:\nodejs\node.exe openclaw.mjs gateway --port 3000 --log-level info
echo echo.
echo echo OpenClaw has stopped.
echo pause
) > "F:\OpenClaw_App\Start_OpenClaw.bat"

REM Create desktop shortcut
echo Creating desktop shortcut...
(
echo Set WshShell = CreateObject("WScript.Shell")
echo Set shortcut = WshShell.CreateShortcut(WshShell.SpecialFolders("Desktop") ^& "\OpenClaw.lnk")
echo shortcut.TargetPath = "F:\OpenClaw_App\Start_OpenClaw.bat"
echo shortcut.WindowStyle = 1
echo shortcut.IconLocation = "shell32.dll,21"
echo shortcut.Description = "OpenClaw Application on F Drive"
echo shortcut.Save
) > "%TEMP%\create_shortcut.vbs"

cscript //nologo "%TEMP%\create_shortcut.vbs"
del "%TEMP%\create_shortcut.vbs"

echo.
echo ✅ OpenClaw application created on F drive!
echo.
echo Location: F:\OpenClaw_App\
echo Launcher: F:\OpenClaw_App\Start_OpenClaw.bat
echo Desktop shortcut: OpenClaw.lnk
echo.
echo To start: Double-click desktop shortcut
echo.
pause