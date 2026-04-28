@echo off
echo ========================================
echo      Node.js & OpenClaw 安装测试
echo ========================================
echo.

echo 1. 测试Node.js安装...
"C:\nodejs\node.exe" --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('"C:\nodejs\node.exe" --version') do (
        echo   ✅ Node.js 版本: %%v
    )
) else (
    echo   ❌ Node.js 测试失败
)

echo.
echo 2. 测试npm安装...
"C:\nodejs\npm.cmd" --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('"C:\nodejs\npm.cmd" --version') do (
        echo   ✅ npm 版本: %%v
    )
) else (
    echo   ❌ npm 测试失败
)

echo.
echo 3. 测试OpenClaw...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw" 2>nul
if %errorlevel% equ 0 (
    "C:\nodejs\node.exe" openclaw.mjs --version >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "delims=" %%v in ('"C:\nodejs\node.exe" openclaw.mjs --version') do (
            echo   ✅ OpenClaw 版本: %%v
        )
    ) else (
        echo   ⚠️  OpenClaw 运行测试失败
    )
) else (
    echo   ❌ OpenClaw 目录不存在
)

echo.
echo 4. PATH环境检查...
echo   当前PATH中的nodejs相关路径:
path | findstr /i node

echo.
echo ========================================
echo 测试完成！
echo.
echo 如果PATH设置正确，您应该能在任何目录运行:
echo   node --version
echo   npm --version
echo.
echo 如果不行，请重启命令行窗口或计算机。
echo ========================================
pause