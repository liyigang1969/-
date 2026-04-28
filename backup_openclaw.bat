@echo off
echo ========================================
echo      OpenClaw 配置备份工具
echo ========================================
echo.

set BACKUP_DIR=E:\openclaw-backup-%date:~0,4%-%date:~5,2%-%date:~8,2%
set SOURCE_DIR=E:\openclaw-data\.openclaw

echo 源目录: %SOURCE_DIR%
echo 备份目录: %BACKUP_DIR%
echo.

if not exist "%SOURCE_DIR%" (
    echo 错误: 源目录不存在!
    pause
    exit /b 1
)

echo 正在创建备份目录...
mkdir "%BACKUP_DIR%" 2>nul
if errorlevel 1 (
    echo 错误: 无法创建备份目录
    pause
    exit /b 1
)

echo 正在备份配置文件...
xcopy "%SOURCE_DIR%\*" "%BACKUP_DIR%\" /E /I /Y

echo.
echo ========================================
echo           备份完成!
echo ========================================
echo.
echo 已备份到: %BACKUP_DIR%
echo.
echo 重要文件:
echo   - 配置: %BACKUP_DIR%\config.json
echo   - 记忆: %BACKUP_DIR%\MEMORY.md
echo   - 工作区: %BACKUP_DIR%\workspace\
echo   - 扩展: %BACKUP_DIR%\extensions\
echo.
pause