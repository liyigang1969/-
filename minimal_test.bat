@echo off
echo 最小化测试 - 按步骤执行
echo.
pause

echo 测试1: 基本命令
echo Hello World
echo.
pause

echo 测试2: 检查Node.js是否存在
if exist "C:\nodejs\node.exe" (
    echo ✅ Node.exe存在
) else (
    echo ❌ Node.exe不存在
)
echo.
pause

echo 测试3: 运行Node.js版本检查
"C:\nodejs\node.exe" --version
echo.
pause

echo 测试4: 检查OpenClaw目录
if exist "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" (
    echo ✅ OpenClaw文件存在
) else (
    echo ❌ OpenClaw文件不存在
)
echo.
pause

echo 测试完成！
pause