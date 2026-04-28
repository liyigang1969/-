@echo off
echo 正在从桌面复制"小星子的记忆"文件夹内容...
echo.

set SOURCE_DIR=C:\Users\YOGA\Desktop\С���ӵļ���
set TARGET_DIR=E:\openclaw-data\.openclaw

echo 源目录: %SOURCE_DIR%
echo 目标目录: %TARGET_DIR%
echo.

REM 检查源目录是否存在
if not exist "%SOURCE_DIR%" (
    echo 错误: 源目录不存在!
    echo 请确认桌面有"小星子的记忆"文件夹
    pause
    exit /b 1
)

echo 正在复制记忆文件...
xcopy "%SOURCE_DIR%\*" "%TARGET_DIR%\" /E /I /Y

echo.
echo 复制完成!
echo.
echo 已复制的文件可能包括:
echo   - 记忆数据库文件 (*.sqlite, *.db)
echo   - 配置文件 (*.json, *.yaml)
echo   - 工作区文件 (*.md)
echo   - 其他记忆文件
echo.
echo 现在可以重启OpenClaw测试记忆是否找回。
echo.
pause