@echo off
echo ========================================
echo     E盘 → F盘 OpenClaw数据迁移工具
echo ========================================
echo.

set SOURCE=E:\openclaw-data\.openclaw
set TARGET=F:\openclaw-data\.openclaw
set BACKUP=F:\openclaw-data-backup\.openclaw

echo 源目录: %SOURCE%
echo 目标目录: %TARGET%
echo 备份目录: %BACKUP%
echo.

echo [1/6] 检查源目录...
if not exist "%SOURCE%" (
    echo ❌ 源目录不存在: %SOURCE%
    pause
    exit /b 1
)
echo ✅ 源目录存在
dir "%SOURCE%" /b | findstr "workspace memory" >nul
if errorlevel 1 (
    echo ⚠️  源目录可能不完整
) else (
    echo ✅ 关键目录存在
)

echo.

echo [2/6] 检查目标目录...
if not exist "%TARGET%" (
    echo ⚠️  目标目录不存在，将创建
    mkdir "%TARGET%" 2>nul
) else (
    echo ✅ 目标目录已存在
    echo   目录内容:
    dir "%TARGET%" /b
)

echo.

echo [3/6] 备份现有数据...
if exist "%TARGET%" (
    echo 正在备份现有数据到: %BACKUP%
    mkdir "%BACKUP%" 2>nul
    xcopy "%TARGET%" "%BACKUP%" /E /I /H /Y /Q
    if errorlevel 1 (
        echo ⚠️  备份过程中有错误
    ) else (
        echo ✅ 备份完成
    )
) else (
    echo ℹ️  无需备份（目标目录为空）
)

echo.

echo [4/6] 迁移数据...
echo 正在从E盘迁移数据到F盘...
xcopy "%SOURCE%" "%TARGET%" /E /I /H /Y
if errorlevel 1 (
    echo ❌ 迁移失败
    pause
    exit /b 1
)
echo ✅ 数据迁移完成

echo.

echo [5/6] 更新配置文件...
if exist "%TARGET%\openclaw.json" (
    echo 更新openclaw.json配置文件...
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   },
        echo   "gateway": {
        echo     "host": "0.0.0.0",
        echo     "port": 3000
        echo   }
        echo }
    ) > "%TARGET%\openclaw.json.new"
    
    move /y "%TARGET%\openclaw.json.new" "%TARGET%\openclaw.json" >nul
    echo ✅ 配置文件更新完成
) else (
    echo ⚠️  未找到openclaw.json，将创建新配置
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   }
        echo }
    ) > "%TARGET%\openclaw.json"
    echo ✅ 新配置文件创建完成
)

echo.

echo [6/6] 创建启动脚本...
(
echo @echo off
echo echo ========================================
echo echo      OpenClaw F盘数据版
echo echo ========================================
echo echo.
echo echo 数据目录: F:\openclaw-data\.openclaw
echo echo.
echo REM 设置环境变量
echo set OPENCLAW_HOME=F:\openclaw-data\.openclaw
echo set OPENCLAW_DATA=F:\openclaw-data\.openclaw
echo.
echo REM 运行OpenClaw
echo cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
echo node openclaw.mjs --data-dir "F:\openclaw-data\.openclaw"
echo.
echo pause
) > "F:\start_openclaw_f.bat"

echo ✅ 启动脚本创建完成: F:\start_openclaw_f.bat
echo.

echo ========================================
echo           迁移完成！
echo ========================================
echo.
echo 迁移摘要:
echo   源: E:\openclaw-data\.openclaw
echo   目标: F:\openclaw-data\.openclaw
echo   备份: F:\openclaw-data-backup\.openclaw
echo   启动脚本: F:\start_openclaw_f.bat
echo.
echo 下一步操作:
echo 1. 测试迁移: 运行 F:\start_openclaw_f.bat
echo 2. 验证数据: 检查workspace和memory目录
echo 3. 功能测试: 测试所有OpenClaw功能
echo 4. 清理E盘: 确认无误后可清理E盘数据
echo.
echo ✅ E盘 → F盘迁移准备就绪！
pause