@echo off
echo ========================================
echo     从GitHub Releases下载OpenClaw
echo ========================================
echo.

set TARGET_DRIVE=F
set OPENCLAW_DIR=%TARGET_DRIVE%:\OpenClaw_Release
set RELEASE_URL=https://github.com/openclaw/openclaw/releases/latest/download/openclaw.zip
set ZIP_FILE=%TARGET_DRIVE%:\openclaw-release.zip

echo 注意: 这将下载预编译的发布版本
echo 目标目录: %OPENCLAW_DIR%
echo 下载地址: %RELEASE_URL%
echo.

echo [1/4] 准备目录...
if exist "%OPENCLAW_DIR%" (
    echo 删除旧目录...
    rmdir /s /q "%OPENCLAW_DIR%" 2>nul
)
mkdir "%OPENCLAW_DIR%" 2>nul
echo ✅ 目录准备完成
echo.

echo [2/4] 下载发布版本...
echo 正在下载最新发布版...
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo 使用curl下载...
    curl -L -o "%ZIP_FILE%" "%RELEASE_URL%"
) else (
    echo 使用bitsadmin下载...
    bitsadmin /transfer openclawrelease /download /priority high "%RELEASE_URL%" "%ZIP_FILE%"
)

if not exist "%ZIP_FILE%" (
    echo ❌ 下载失败
    echo 备用方案: 手动下载
    echo 1. 访问: https://github.com/openclaw/openclaw/releases/latest
    echo 2. 下载 openclaw.zip
    echo 3. 保存到: %ZIP_FILE%
    pause
    exit /b 1
)

echo ✅ 下载完成
for %%F in ("%ZIP_FILE%") do (
    set /a SIZE=%%~zF/1048576
    echo 文件大小: !SIZE! MB
)
echo.

echo [3/4] 解压文件...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%OPENCLAW_DIR%' -Force"
if errorlevel 1 (
    echo ❌ 解压失败，尝试tar...
    "C:\Windows\System32\tar.exe" -xf "%ZIP_FILE%" -C "%OPENCLAW_DIR%"
)

echo ✅ 解压完成
echo.

echo [4/4] 验证和配置...
echo 检查文件...

if exist "%OPENCLAW_DIR%\openclaw.mjs" (
    echo ✅ openclaw.mjs 存在
    cd /d "%OPENCLAW_DIR%"
    node openclaw.mjs --version >nul 2>&1
    if errorlevel 1 (
        echo ⚠️  运行测试失败
    ) else (
        for /f "delims=" %%v in ('node openclaw.mjs --version 2^>nul') do (
            echo ✅ 版本: %%v
        )
    )
) else (
    echo ❌ openclaw.mjs 缺失
    dir "%OPENCLAW_DIR%" /b
)

echo.
echo 创建F盘启动脚本...
(
echo @echo off
echo echo ========================================
echo echo     OpenClaw F盘最新版
echo echo ========================================
echo echo.
echo set OPENCLAW_DIR=%OPENCLAW_DIR%
echo set OPENCLAW_DATA=F:\openclaw-data\.openclaw
echo.
echo echo 程序目录: %%OPENCLAW_DIR%%
echo echo 数据目录: %%OPENCLAW_DATA%%
echo echo.
echo if not exist "%%OPENCLAW_DATA%%" (
echo     echo ❌ 数据目录不存在
echo     pause
echo     exit /b 1
echo )
echo.
echo cd /d "%%OPENCLAW_DIR%%"
echo node openclaw.mjs --data-dir "%%OPENCLAW_DATA%%"
echo.
echo pause
) > "%TARGET_DRIVE%:\start_openclaw_latest.bat"

echo ✅ 启动脚本创建: %TARGET_DRIVE%:\start_openclaw_latest.bat
echo.
echo 清理下载文件...
del "%ZIP_FILE%" 2>nul

echo.
echo ========================================
echo ✅ 发布版下载完成！
echo.
echo 使用方法:
echo 1. 运行: %TARGET_DRIVE%:\start_openclaw_latest.bat
echo 2. 或手动: cd /d "%OPENCLAW_DIR%" && node openclaw.mjs --data-dir "F:\openclaw-data\.openclaw"
echo.
echo 注意: 如果仍有"远程关闭，退出码1"错误
echo 可能需要检查Node.js版本或配置文件
echo ========================================
pause