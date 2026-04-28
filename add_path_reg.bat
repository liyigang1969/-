@echo off
echo ========================================
echo      Node.js PATH 设置工具
echo ========================================
echo.

REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 需要以管理员身份运行
    echo 请右键点击"命令提示符"，选择"以管理员身份运行"
    echo 然后再次运行此脚本
    pause
    exit /b 1
)

echo 正在检查Node.js目录...
if not exist "C:\nodejs\node.exe" (
    echo 错误: Node.js未安装在 C:\nodejs
    pause
    exit /b 1
)

echo ✅ Node.js目录存在
echo.

echo 正在读取当前系统PATH...
for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "CURRENT_PATH=%%B"

echo 检查是否已包含Node.js路径...
echo %CURRENT_PATH% | findstr /i /c:"C:\\nodejs" >nul
if %errorlevel% equ 0 (
    echo ✅ PATH中已包含Node.js路径
    echo 无需更改
    goto :test
)

echo 正在添加Node.js路径到系统PATH...
set "NEW_PATH=%CURRENT_PATH%;C:\nodejs"

echo 更新注册表...
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%NEW_PATH%" /f

if %errorlevel% equ 0 (
    echo ✅ 系统PATH更新成功!
    
    REM 广播环境变量更改
    echo 通知系统环境变量已更改...
    setx Path "%NEW_PATH%" /m >nul
) else (
    echo ❌ PATH更新失败
    pause
    exit /b 1
)

:test
echo.
echo ========================================
echo           测试设置
echo ========================================
echo.

echo 1. 测试node命令...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('node --version 2^>nul') do (
        echo   ✅ Node.js 版本: %%v
    )
) else (
    echo   ⚠️  node命令不可用（可能需要重启）
)

echo.
echo 2. 测试npm命令...
where npm >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('npm --version 2^>nul') do (
        echo   ✅ npm 版本: %%v
    )
) else (
    echo   ⚠️  npm命令不可用（可能需要重启）
)

echo.
echo 3. 测试OpenClaw...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw" 2>nul
if %errorlevel% equ 0 (
    node openclaw.mjs --version >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "delims=" %%v in ('node openclaw.mjs --version 2^>nul') do (
            echo   ✅ OpenClaw 版本: %%v
        )
    ) else (
        echo   ⚠️  OpenClaw运行测试失败
    )
) else (
    echo   ❌ OpenClaw目录不存在
)

echo.
echo ========================================
echo           重要提示
echo ========================================
echo 1. 可能需要重启计算机使PATH更改完全生效
echo 2. 或者至少重启所有命令行窗口
echo 3. 新窗口应该能直接使用: node --version
echo 4. 测试命令: npm --version
echo.
echo ✅ PATH设置完成!
echo ========================================
pause