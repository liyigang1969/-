@echo off
echo 正在创建 OpenClaw 桌面快捷方式...
echo.

set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\OpenClaw.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "E:\启动OpenClaw.vbs" >> %SCRIPT%
echo oLink.IconLocation = "E:\OpenClaw-U盘版.exe, 0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%

echo 桌面快捷方式创建完成！
echo.
echo 现在您可以通过以下方式启动 OpenClaw：
echo 1. 双击桌面上的 "OpenClaw" 快捷方式
echo 2. 或直接双击 E:\启动OpenClaw.vbs
echo 3. 或双击 E:\启动OpenClaw.bat
echo.
pause