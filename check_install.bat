@echo off
echo ========================================
echo      Node.js 安装状态检查
echo ========================================
echo.

echo 1. 检查安装文件...
if exist "C:\Users\lenovo\Downloads\node-v22.22.2-x64.msi" (
    echo   ✅ 安装文件存在
    for %%F in ("C:\Users\lenovo\Downloads\node-v22.22.2-x64.msi") do (
        echo   📏 文件大小: %%~zF 字节
    )
) else (
    echo   ❌ 安装文件不存在
)

echo.
echo 2. 检查安装进程...
tasklist | findstr /i msiexec >nul
if %errorlevel% equ 0 (
    echo   ⚠️  msiexec进程仍在运行
    tasklist | findstr /i msiexec
) else (
    echo   ✅ 无msiexec进程运行
)

echo.
echo 3. 检查Node.js安装目录...
if exist "C:\Program Files\nodejs\" (
    echo   ✅ Node.js目录存在: C:\Program Files\nodejs
    dir "C:\Program Files\nodejs" | findstr "node.exe"
) else (
    echo   ❌ Node.js目录不存在: C:\Program Files\nodejs
)

if exist "C:\Program Files (x86)\nodejs\" (
    echo   ✅ Node.js目录存在: C:\Program Files (x86)\nodejs
) else (
    echo   ❌ Node.js目录不存在: C:\Program Files (x86)\nodejs
)

echo.
echo 4. 检查Node.js命令...
where node >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ node命令可用
    for /f "delims=" %%v in ('node --version 2^>nul') do echo   📦 版本: %%v
) else (
    echo   ❌ node命令不可用
)

where npm >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ npm命令可用
    for /f "delims=" %%v in ('npm --version 2^>nul') do echo   📦 版本: %%v
) else (
    echo   ❌ npm命令不可用
)

echo.
echo 5. 测试OpenClaw...
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw" 2>nul
if %errorlevel% equ 0 (
    node openclaw.mjs --version >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "delims=" %%v in ('node openclaw.mjs --version 2^>nul') do (
            echo   ✅ OpenClaw版本: %%v
        )
    ) else (
        echo   ⚠️  OpenClaw运行失败
    )
) else (
    echo   ❌ OpenClaw目录不存在
)

echo.
echo ========================================
echo 检查完成
echo ========================================
pause