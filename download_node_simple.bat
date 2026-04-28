@echo off
echo ========================================
echo      Node.js ZIP 下载工具
echo ========================================
echo.

set DOWNLOAD_URL=https://nodejs.org/dist/latest-v22.x/node-v22.22.2-win-x64.zip
set ZIP_FILE=C:\Users\lenovo\Downloads\node-v22.22.2-win-x64.zip

echo 正在下载 Node.js v22.22.2...
echo 从: %DOWNLOAD_URL%
echo 到: %ZIP_FILE%
echo.

REM 使用curl下载（如果可用）
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo 使用curl下载...
    curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"
) else (
    echo 使用bitsadmin下载...
    bitsadmin /transfer nodedownload /download /priority high "%DOWNLOAD_URL%" "%ZIP_FILE%"
)

if exist "%ZIP_FILE%" (
    echo.
    echo ✅ 下载成功!
    for %%F in ("%ZIP_FILE%") do (
        set /a SIZE=%%~zF/1048576
        echo 📦 文件大小: !SIZE! MB
    )
    
    echo.
    echo 下一步：解压文件
    echo 请运行解压脚本
) else (
    echo.
    echo ❌ 下载失败
    echo 请手动下载: %DOWNLOAD_URL%
)

echo.
pause