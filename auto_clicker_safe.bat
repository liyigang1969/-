@echo off
chcp 65001 >nul
title 安全自动点击器 - 按Ctrl+C停止

echo ========================================
echo 🖱️ 安全自动点击器 v1.0
echo ========================================
echo.
echo 这是一个安全的自动化程序
echo 不会进行任何有害操作
echo.
echo 功能:
echo   1. 记录运行时间
echo   2. 模拟用户活动
echo   3. 防止系统休眠
echo   4. 安全循环操作
echo.
echo 按 Ctrl+C 停止程序
echo ========================================
echo.

set loop_count=0
set start_time=%time%

:main_loop
set /a loop_count+=1
set current_time=%time%

echo [%current_time%] 循环 %loop_count% - 运行中...
echo   状态: 正常
echo   运行时间: 从 %start_time% 开始
echo.

:: 这里可以添加安全的自动化操作
:: 例如使用 PowerShell 进行简单操作

:: 使用 PowerShell 移动鼠标到当前位置（无害）
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Cursor]::Position = [System.Windows.Forms.Cursor]::Position"

:: 简单的等待
timeout /t 10 /nobreak >nul

:: 每10次循环显示状态
set /a mod_result=loop_count %% 10
if %mod_result% equ 0 (
    echo ========================================
    echo 📊 状态报告
    echo   总循环次数: %loop_count%
    echo   开始时间: %start_time%
    echo   当前时间: %current_time%
    echo ========================================
    echo.
)

goto main_loop

:cleanup
echo.
echo ========================================
echo 🛑 程序停止
echo ========================================
echo 总循环次数: %loop_count%
echo 开始时间: %start_time%
echo 结束时间: %time%
echo.
echo 感谢使用安全自动点击器
echo ========================================
pause
exit /b 0