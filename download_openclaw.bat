@echo off
echo 正在下载 OpenClaw 最新版本 (2026.4.14)...

REM 下载链接
set DOWNLOAD_URL=https://github.com/openclaw/openclaw/archive/refs/tags/v2026.4.14.zip
set OUTPUT_FILE=openclaw-2026.4.14.zip
set EXTRACT_DIR=openclaw-2026.4.14

echo.
echo 下载链接: %DOWNLOAD_URL%
echo 输出文件: %OUTPUT_FILE%
echo 解压目录: %EXTRACT_DIR%
echo.

REM 检查是否已有文件
if exist "%OUTPUT_FILE%" (
    echo 文件已存在，跳过下载。
    goto EXTRACT
)

REM 尝试使用不同的方法下载
echo 尝试使用 PowerShell 下载...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%OUTPUT_FILE%'"

if exist "%OUTPUT_FILE%" (
    echo 下载成功!
) else (
    echo 下载失败，请手动下载:
    echo %DOWNLOAD_URL%
    pause
    exit /b 1
)

:EXTRACT
echo.
echo 正在解压文件...

if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"

REM 尝试解压
powershell -Command "Expand-Archive -Path '%OUTPUT_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"

if exist "%EXTRACT_DIR%\openclaw-2026.4.14" (
    echo 解压成功!
    echo 文件位于: %EXTRACT_DIR%\openclaw-2026.4.14
) else (
    echo 解压失败，请手动解压。
)

echo.
echo 安装步骤:
echo 1. 进入目录: cd %EXTRACT_DIR%\openclaw-2026.4.14
echo 2. 安装依赖: npm install
echo 3. 复制配置文件
echo 4. 启动: node openclaw.mjs
echo.
pause