@echo off
chcp 65001 >nul
echo ========================================
echo 🖱️⌨️ 鼠标键盘自动化批处理程序
echo ========================================
echo.
echo 这是一个简单的自动化循环程序
echo 可以模拟基本的鼠标和键盘操作
echo.
echo 按 Ctrl+C 停止程序
echo ========================================
echo.

:loop
echo [%time%] 循环运行中...
echo   模拟操作 1: 移动鼠标到安全位置
echo   模拟操作 2: 发送无害的键盘输入
echo   模拟操作 3: 短暂等待
echo.

:: 这里可以添加实际的自动化命令
:: 例如使用 AutoHotkey 或其他自动化工具

:: 简单的等待
timeout /t 5 /nobreak >nul

goto loop