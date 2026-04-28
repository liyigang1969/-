@echo off
echo === OpenClaw 简单测试 ===
echo.
pause

echo 1. 测试Node.js...
C:\nodejs\node.exe --version
if errorlevel 1 echo ❌ Node.js测试失败
echo.

echo 2. 测试F盘目录...
dir F:\openclaw-data\.openclaw
if errorlevel 1 echo ❌ F盘目录访问失败
echo.

echo 3. 测试OpenClaw基本功能...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
C:\nodejs\node.exe openclaw.mjs --version
if errorlevel 1 echo ❌ OpenClaw测试失败
echo.

echo 测试完成！
pause