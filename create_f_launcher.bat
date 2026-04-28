@echo off
echo Creating F drive OpenClaw launcher...
echo.

REM Create the launcher content
(
echo @echo off
echo echo OpenClaw F Drive Launcher
echo echo ==========================
echo echo.
echo echo Using port 3005 to avoid conflicts with E drive
echo echo.
echo REM Set F drive environment
echo set OPENCLAW_DATA=F:\OpenClaw_System\data\.openclaw
echo set OPENCLAW_STATE_DIR=F:\OpenClaw_System\data\.openclaw
echo set OPENCLAW_PORT=3005
echo.
echo echo Starting OpenClaw F Drive Edition...
echo echo Port: %%OPENCLAW_PORT%%
echo echo.
echo cd /d "F:\OpenClaw_System\program"
echo C:\nodejs\node.exe openclaw.mjs gateway --port %%OPENCLAW_PORT%% --log-level info
echo.
echo echo.
echo pause
) > "F:\OpenClaw_F_Drive.bat"

echo Launcher created: F:\OpenClaw_F_Drive.bat
echo.
echo Also creating shortcut on desktop...
(
echo Set WshShell = CreateObject("WScript.Shell")
echo Set oShellLink = WshShell.CreateShortcut(WshShell.SpecialFolders("Desktop") ^& "\OpenClaw F Drive.lnk")
echo oShellLink.TargetPath = "F:\OpenClaw_F_Drive.bat"
echo oShellLink.WindowStyle = 1
echo oShellLink.IconLocation = "shell32.dll,21"
echo oShellLink.Save
) > "%TEMP%\create_shortcut.vbs"

cscript //nologo "%TEMP%\create_shortcut.vbs"
del "%TEMP%\create_shortcut.vbs"

echo.
echo ✅ F drive OpenClaw setup complete!
echo.
echo To start OpenClaw from F drive:
echo 1. Double-click: F:\OpenClaw_F_Drive.bat
echo 2. Or use desktop shortcut: "OpenClaw F Drive"
echo.
echo This uses port 3005 to avoid conflicts with E drive.
echo.
pause