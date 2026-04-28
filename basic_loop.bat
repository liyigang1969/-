@echo off
chcp 65001 >nul
title 基本循环程序 - 按Ctrl+C停止

echo ========================================
echo 🔄 基本循环程序 v1.0
echo ========================================
echo.
echo 最简单的循环程序
echo 只做一件事：循环运行
echo.
echo 用途：
echo   - 保持程序运行
echo   - 模拟持续活动
echo   - 防止超时断开
echo.
echo 按 Ctrl+C 停止
echo ========================================
echo.

set count=0
set start_time=%time%

echo 开始时间: %start_time%
echo 程序开始运行...
echo.

:loop
set /a count+=1
set current_time=%time%

:: 显示状态
echo [%current_time%] 循环 %count% 次

:: 每10次显示一次详细状态
set /a mod=count %% 10
if %mod%==0 (
    echo ----------------------------------------
    echo 📊 状态报告
    echo   循环次数: %count%
    echo   运行时间: 从 %start_time% 开始
    echo   当前时间: %current_time%
    echo ----------------------------------------
)

:: 简单的等待
timeout /t 3 /nobreak >nul

goto loop

:end
echo.
echo ========================================
echo 🛑 程序已停止
echo ========================================
echo 总循环次数: %count%
echo 开始时间: %start_time%
echo 结束时间: %time%
echo.
pause
exit /b 0