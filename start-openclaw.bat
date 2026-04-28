@echo off
chcp 65001 >nul
echo.
echo ========================================
echo      🧠 OpenClaw 智能助手启动器
echo ========================================
echo.

REM 运行记忆回顾
echo [1/3] 正在回顾记忆...
powershell -ExecutionPolicy Bypass -File "E:\openclaw-data\.openclaw\workspace\memory-review.ps1"

echo.
echo [2/3] 正在启动OpenClaw...
echo.

REM 启动OpenClaw
cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
node openclaw.mjs

echo.
echo [3/3] OpenClaw已停止
pause