@echo off
echo ========================================
echo      Node.js 安装程序
echo ========================================
echo.

set MSI_PATH=C:\Users\lenovo\Downloads\node-v22.22.2-x64.msi

if not exist "%MSI_PATH%" (
    echo 错误: 安装文件不存在
    echo 请确保文件存在: %MSI_PATH%
    pause
    exit /b 1
)

echo 找到安装文件: %MSI_PATH%
for %%F in ("%MSI_PATH%") do set FILE_SIZE=%%~zF
set /a FILE_SIZE_MB=FILE_SIZE/1048576
echo 文件大小: %FILE_SIZE_MB% MB
echo.

echo 正在安装 Node.js v22.22.2...
echo 这可能需要几分钟时间，请稍候...
echo.

msiexec /i "%MSI_PATH%" /quiet ADDLOCAL=NodeRuntime,npm,DocumentationShortcuts,EnvironmentPathNode,EnvironmentPathNpm

if %errorlevel% equ 0 (
    echo.
    echo ✅ Node.js 安装成功!
    echo.
    
    echo 验证安装...
    echo.
    
    where node >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "delims=" %%v in ('node --version') do set NODE_VERSION=%%v
        echo Node.js 版本: %NODE_VERSION%
    ) else (
        echo ❌ Node.js 未正确安装
    )
    
    where npm >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "delims=" %%v in ('npm --version') do set NPM_VERSION=%%v
        echo npm 版本: %NPM_VERSION%
    ) else (
        echo ⚠️  npm 未正确安装
    )
    
    echo.
    echo 测试 OpenClaw...
    cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
    if %errorlevel% equ 0 (
        node openclaw.mjs --version >nul 2>&1
        if %errorlevel% equ 0 (
            for /f "delims=" %%v in ('node openclaw.mjs --version') do set OPENCLAW_VERSION=%%v
            echo OpenClaw 版本: %OPENCLAW_VERSION%
            echo ✅ OpenClaw 可以正常运行!
        ) else (
            echo ⚠️  OpenClaw 运行测试失败
        )
    ) else (
        echo ❌ OpenClaw 目录不存在
    )
    
) else (
    echo.
    echo ❌ Node.js 安装失败，错误代码: %errorlevel%
)

echo.
echo ========================================
echo 安装完成!
echo 注意: 可能需要重启命令行窗口以使PATH更改生效
echo ========================================
pause