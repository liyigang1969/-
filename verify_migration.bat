@echo off
echo ========================================
echo     迁移验证工具
echo ========================================
echo.

if "%1"=="" (
    echo 用法: verify_migration.bat [目标盘符]
    echo 示例: verify_migration.bat G
    pause
    exit /b 1
)

set TARGET_DRIVE=%1
set TARGET_PROGRAM=%TARGET_DRIVE%:\OpenClaw
set TARGET_DATA=%TARGET_DRIVE%:\openclaw-data\.openclaw

echo 验证目标: %TARGET_DRIVE%:盘
echo.

echo [1/4] 检查目录结构...
if not exist "%TARGET_PROGRAM%" (
    echo ❌ 程序目录不存在: %TARGET_PROGRAM%
) else (
    echo ✅ 程序目录存在
    dir "%TARGET_PROGRAM%" /b | findstr "openclaw.mjs" >nul
    if errorlevel 1 (
        echo ❌ 缺少 openclaw.mjs
    ) else (
        echo ✅ 找到 openclaw.mjs
    )
)

if not exist "%TARGET_DATA%" (
    echo ❌ 数据目录不存在: %TARGET_DATA%
) else (
    echo ✅ 数据目录存在
)

echo.

echo [2/4] 检查关键文件...
set MISSING=0

if not exist "%TARGET_DATA%\workspace\AGENTS.md" (
    echo ❌ 缺少 workspace/AGENTS.md
    set /a MISSING+=1
)

if not exist "%TARGET_DATA%\workspace\SOUL.md" (
    echo ❌ 缺少 workspace/SOUL.md
    set /a MISSING+=1
)

if not exist "%TARGET_DATA%\memory\*.md" (
    echo ⚠️  记忆文件可能未迁移
    set /a MISSING+=1
)

if %MISSING% equ 0 (
    echo ✅ 所有关键文件存在
)

echo.

echo [3/4] 测试OpenClaw运行...
cd /d "%TARGET_PROGRAM%" 2>nul
if errorlevel 1 (
    echo ❌ 无法进入程序目录
) else (
    node openclaw.mjs --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ OpenClaw运行测试失败
    ) else (
        for /f "delims=" %%v in ('node openclaw.mjs --version 2^>nul') do (
            echo ✅ OpenClaw版本: %%v
        )
    )
)

echo.

echo [4/4] 空间检查...
for /f "tokens=3" %%a in ('dir "%TARGET_PROGRAM%" /a /s ^| findstr "个文件"') do (
    set PROGRAM_SIZE=%%a
)
for /f "tokens=3" %%a in ('dir "%TARGET_DATA%" /a /s ^| findstr "个文件"') do (
    set DATA_SIZE=%%a
)

echo   程序文件: !PROGRAM_SIZE!
echo   数据文件: !DATA_SIZE!

echo.
echo ========================================
if %MISSING% equ 0 (
    echo ✅ 迁移验证通过！
    echo 可以安全使用4T U盘上的OpenClaw
) else (
    echo ⚠️  迁移验证发现 %MISSING% 个问题
    echo 请检查缺失的文件
)
echo ========================================
pause