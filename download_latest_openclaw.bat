@echo off
echo ========================================
echo     下载最新版OpenClaw到F盘
echo ========================================
echo.

set TARGET_DRIVE=F
set OPENCLAW_DIR=%TARGET_DRIVE%:\OpenClaw_Latest
set DOWNLOAD_URL=https://github.com/openclaw/openclaw/archive/refs/heads/main.zip
set ZIP_FILE=%TARGET_DRIVE%:\openclaw-main.zip

echo 目标目录: %OPENCLAW_DIR%
echo 下载地址: %DOWNLOAD_URL%
echo.

echo [1/5] 准备目录...
if exist "%OPENCLAW_DIR%" (
    echo 删除旧目录...
    rmdir /s /q "%OPENCLAW_DIR%" 2>nul
)
mkdir "%OPENCLAW_DIR%" 2>nul
if not exist "%OPENCLAW_DIR%" (
    echo ❌ 无法创建目录
    pause
    exit /b 1
)
echo ✅ 目录准备完成
echo.

echo [2/5] 下载最新版OpenClaw...
echo 正在下载，这可能需要一些时间...
echo 从: %DOWNLOAD_URL%
echo 到: %ZIP_FILE%

REM 尝试使用不同的下载方法
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo 使用curl下载...
    curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"
) else (
    echo 使用bitsadmin下载...
    bitsadmin /transfer openclawdownload /download /priority high "%DOWNLOAD_URL%" "%ZIP_FILE%"
)

if not exist "%ZIP_FILE%" (
    echo ❌ 下载失败
    echo 请手动下载: %DOWNLOAD_URL%
    echo 保存为: %ZIP_FILE%
    pause
    exit /b 1
)

echo ✅ 下载完成
for %%F in ("%ZIP_FILE%") do (
    set /a SIZE=%%~zF/1048576
    echo 文件大小: !SIZE! MB
)
echo.

echo [3/5] 解压文件...
echo 正在解压到: %OPENCLAW_DIR%
"C:\Windows\System32\tar.exe" -xf "%ZIP_FILE%" -C "%OPENCLAW_DIR%"

if errorlevel 1 (
    echo ❌ 解压失败
    echo 尝试使用Expand-Archive...
    powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%OPENCLAW_DIR%' -Force"
    if errorlevel 1 (
        echo ❌ 所有解压方法都失败
        pause
        exit /b 1
    )
)

echo ✅ 解压完成
echo.

echo [4/5] 整理目录结构...
REM 查找解压后的主目录
for /d %%d in ("%OPENCLAW_DIR%\openclaw-main*") do (
    set EXTRACTED_DIR=%%d
)

if not defined EXTRACTED_DIR (
    echo ⚠️  未找到解压目录，检查文件结构
    dir "%OPENCLAW_DIR%" /b
) else (
    echo 找到解压目录: !EXTRACTED_DIR!
    
    REM 移动文件到正确位置
    echo 整理文件...
    xcopy "!EXTRACTED_DIR!\*" "%OPENCLAW_DIR%" /E /I /H /Y /Q
    
    REM 清理临时目录
    rmdir /s /q "!EXTRACTED_DIR!" 2>nul
    
    echo ✅ 目录整理完成
)

echo.

echo [5/5] 验证安装...
echo 检查关键文件...

set MISSING=0

if exist "%OPENCLAW_DIR%\openclaw.mjs" (
    echo ✅ openclaw.mjs 存在
) else (
    echo ❌ openclaw.mjs 缺失
    set /a MISSING+=1
)

if exist "%OPENCLAW_DIR%\package.json" (
    echo ✅ package.json 存在
    
    REM 检查版本
    for /f "tokens=2 delims=:," %%v in ('type "%OPENCLAW_DIR%\package.json" ^| findstr "version"') do (
        set VERSION=%%v
    )
    echo 版本: !VERSION!
) else (
    echo ❌ package.json 缺失
    set /a MISSING+=1
)

if exist "%OPENCLAW_DIR%\dist" (
    echo ✅ dist目录存在
) else (
    echo ⚠️  dist目录缺失
)

if exist "%OPENCLAW_DIR%\skills" (
    echo ✅ skills目录存在
) else (
    echo ⚠️  skills目录缺失
)

echo.
echo 清理下载文件...
del "%ZIP_FILE%" 2>nul

echo.
echo ========================================
if %MISSING% equ 0 (
    echo ✅ 最新版OpenClaw下载完成！
    echo.
    echo 安装位置: %OPENCLAW_DIR%
    echo 版本: !VERSION!
    echo.
    echo 下一步:
    echo   1. 测试运行: cd /d "%OPENCLAW_DIR%" && node openclaw.mjs --version
    echo   2. 配置数据目录: --data-dir "F:\openclaw-data\.openclaw"
    echo   3. 创建启动脚本
) else (
    echo ⚠️  下载完成但有缺失文件
    echo 请检查目录: %OPENCLAW_DIR%
)
echo ========================================
pause