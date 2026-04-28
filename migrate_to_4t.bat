@echo off
echo ========================================
echo     OpenClaw 迁移到4T U盘工具
echo ========================================
echo.

REM 检查参数
if "%1"=="" (
    echo 用法: migrate_to_4t.bat [目标盘符]
    echo 示例: migrate_to_4t.bat G
    echo.
    echo 请先插入4T U盘并记下盘符
    pause
    exit /b 1
)

set TARGET_DRIVE=%1
set SOURCE_PROGRAM=C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw
set SOURCE_DATA=E:\openclaw-data\.openclaw
set TARGET_PROGRAM=%TARGET_DRIVE%:\OpenClaw
set TARGET_DATA=%TARGET_DRIVE%:\openclaw-data\.openclaw

echo 正在检查目标U盘...
if not exist %TARGET_DRIVE%:\ (
    echo 错误: 目标驱动器 %TARGET_DRIVE%: 不存在
    pause
    exit /b 1
)

echo ✅ 找到目标驱动器: %TARGET_DRIVE%:
echo.

echo [1/5] 检查源文件...
if not exist "%SOURCE_PROGRAM%" (
    echo 错误: OpenClaw程序目录不存在
    echo 路径: %SOURCE_PROGRAM%
    pause
    exit /b 1
)

if not exist "%SOURCE_DATA%" (
    echo 错误: OpenClaw数据目录不存在
    echo 路径: %SOURCE_DATA%
    pause
    exit /b 1
)

echo ✅ 源文件检查通过
echo.

echo [2/5] 创建目标目录结构...
mkdir "%TARGET_PROGRAM%" 2>nul
mkdir "%TARGET_DATA%" 2>nul

echo ✅ 目录创建完成
echo.

echo [3/5] 复制程序文件...
echo 正在复制，这可能需要几分钟...
xcopy "%SOURCE_PROGRAM%" "%TARGET_PROGRAM%" /E /I /H /Y /Q
if errorlevel 1 (
    echo ❌ 程序文件复制失败
    pause
    exit /b 1
)
echo ✅ 程序文件复制完成
echo.

echo [4/5] 复制数据文件...
xcopy "%SOURCE_DATA%" "%TARGET_DATA%" /E /I /H /Y /Q
if errorlevel 1 (
    echo ❌ 数据文件复制失败
    pause
    exit /b 1
)
echo ✅ 数据文件复制完成
echo.

echo [5/5] 创建启动脚本...
(
echo @echo off
echo echo ========================================
echo echo      OpenClaw 4T U盘版 - ^%TARGET_DRIVE%^:盘
echo echo ========================================
echo echo.
echo set OPENCLAW_DIR=%TARGET_PROGRAM%
echo set OPENCLAW_DATA=%TARGET_DATA%
echo.
echo set OPENCLAW_HOME=%%OPENCLAW_DATA%%
echo set NODE_PATH=%%OPENCLAW_DIR%%\node_modules
echo.
echo cd /d "%%OPENCLAW_DIR%%"
echo echo 正在启动OpenClaw...
echo node openclaw.mjs
echo.
echo pause
) > "%TARGET_DRIVE%:\start_openclaw.bat"

echo ✅ 启动脚本创建完成: %TARGET_DRIVE%:\start_openclaw.bat
echo.

echo ========================================
echo           迁移完成！
echo ========================================
echo.
echo 迁移摘要:
echo   程序文件: %SOURCE_PROGRAM% → %TARGET_PROGRAM%
echo   数据文件: %SOURCE_DATA% → %TARGET_DATA%
echo   启动脚本: %TARGET_DRIVE%:\start_openclaw.bat
echo.
echo 下一步操作:
echo 1. 测试迁移: 运行 %TARGET_DRIVE%:\start_openclaw.bat
echo 2. 验证功能: 检查所有功能是否正常
echo 3. 备份原U盘: 确认无误后再清理原U盘
echo.
echo ✅ 迁移成功完成！
pause