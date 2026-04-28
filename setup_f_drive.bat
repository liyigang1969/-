REM Setup F Drive OpenClaw
echo Setting up F drive OpenClaw...

REM Create directories
mkdir "F:\OpenClaw_System" 2>nul
mkdir "F:\OpenClaw_System\program" 2>nul
mkdir "F:\OpenClaw_System\data" 2>nul
mkdir "F:\OpenClaw_System\data\.openclaw" 2>nul

REM Copy OpenClaw files
xcopy "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\*" "F:\OpenClaw_System\program" /E /I /H /Y /Q

REM Create launcher
echo @echo off > "F:\OpenClaw_F_Drive.bat"
echo echo OpenClaw F Drive Edition >> "F:\OpenClaw_F_Drive.bat"
echo echo ======================== >> "F:\OpenClaw_F_Drive.bat"
echo echo. >> "F:\OpenClaw_F_Drive.bat"
echo echo Port: 3005 ^(avoids conflict with E drive^) >> "F:\OpenClaw_F_Drive.bat"
echo echo. >> "F:\OpenClaw_F_Drive.bat"
echo set OPENCLAW_DATA=F:\OpenClaw_System\data\.openclaw >> "F:\OpenClaw_F_Drive.bat"
echo set OPENCLAW_PORT=3005 >> "F:\OpenClaw_F_Drive.bat"
echo echo. >> "F:\OpenClaw_F_Drive.bat"
echo cd /d "F:\OpenClaw_System\program" >> "F:\OpenClaw_F_Drive.bat"
echo C:\nodejs\node.exe openclaw.mjs gateway --port %%OPENCLAW_PORT%% --log-level info >> "F:\OpenClaw_F_Drive.bat"
echo echo. >> "F:\OpenClaw_F_Drive.bat"
echo pause >> "F:\OpenClaw_F_Drive.bat"

echo Setup complete!
echo Run: F:\OpenClaw_F_Drive.bat
pause