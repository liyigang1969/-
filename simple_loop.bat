@echo off
title Simple Loop Program - Press Ctrl+C to stop

echo ========================================
echo Simple Loop Program v1.0
echo ========================================
echo.
echo This is a simple loop program
echo It just runs in a loop
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

set count=0
set start_time=%time%

echo Start time: %start_time%
echo Program started...
echo.

:loop
set /a count+=1
set current_time=%time%

echo [%current_time%] Loop %count%

:: Show status every 10 loops
set /a mod=count %% 10
if %mod%==0 (
    echo ----------------------------------------
    echo Status Report
    echo   Loops: %count%
    echo   Start: %start_time%
    echo   Current: %current_time%
    echo ----------------------------------------
)

:: Wait 3 seconds
timeout /t 3 /nobreak >nul

goto loop

:end
echo.
echo ========================================
echo Program Stopped
echo ========================================
echo Total loops: %count%
echo Start time: %start_time%
echo End time: %time%
echo.
pause
exit /b 0