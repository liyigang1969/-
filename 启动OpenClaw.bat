@echo off
echo 正在启动 OpenClaw...
echo.

REM 检查OpenClaw-U盘版.exe是否存在
if exist "E:\OpenClaw-U盘版.exe" (
    echo 找到 OpenClaw-U盘版.exe，正在启动...
    start "" "E:\OpenClaw-U盘版.exe"
) else (
    echo 错误：未找到 OpenClaw-U盘版.exe
    echo 请确保文件存在于 E:\ 根目录
)

REM 检查F盘上的OpenClaw系统
if exist "F:\OpenClaw_System" (
    echo.
    echo 检测到F盘上的OpenClaw系统文件
    echo 位置：F:\OpenClaw_System
)

echo.
echo 启动脚本执行完成
pause