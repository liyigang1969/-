@echo off
chcp 65001 >nul
title 工作自动化助手 - 安全循环程序

echo ========================================
echo 🤖 工作自动化助手 v1.0
echo ========================================
echo.
echo 这是一个安全的自动化工作程序
echo 模拟常见的用户工作模式
echo.
echo 自动化模式:
echo   1. 文档处理模拟
echo   2. 浏览器操作模拟
echo   3. 文件管理模拟
echo   4. 系统维护模拟
echo.
echo 按 Ctrl+C 停止程序
echo ========================================
echo.

set mode=1
set cycle=0
set total_cycles=0

:mode_select
echo 请选择自动化模式:
echo   1. 文档处理模式 (默认)
echo   2. 浏览器操作模式
echo   3. 文件管理模式
echo   4. 系统维护模式
echo   5. 混合模式
echo.
set /p mode="选择模式 (1-5): "
if "%mode%"=="" set mode=1
if %mode% LSS 1 set mode=1
if %mode% GTR 5 set mode=5

cls
echo ========================================
echo 🤖 启动自动化模式 %mode%
echo ========================================
echo.

:main_loop
set /a total_cycles+=1
set /a cycle+=1
set current_time=%time%

echo [%current_time%] 周期 %cycle% - 模式 %mode% - 运行中...

:: 根据模式执行不同的自动化任务
if %mode%==1 (
    echo   正在模拟文档处理...
    echo   - 模拟打字输入
    echo   - 模拟格式调整
    echo   - 模拟保存操作
)

if %mode%==2 (
    echo   正在模拟浏览器操作...
    echo   - 模拟网页浏览
    echo   - 模拟标签切换
    echo   - 模拟滚动阅读
)

if %mode%==3 (
    echo   正在模拟文件管理...
    echo   - 模拟文件整理
    echo   - 模拟文件夹导航
    echo   - 模拟文件操作
)

if %mode%==4 (
    echo   正在模拟系统维护...
    echo   - 模拟系统检查
    echo   - 模拟清理操作
    echo   - 模拟优化设置
)

if %mode%==5 (
    echo   正在混合模式运行...
    set /a current_task=total_cycles %% 4 + 1
    echo   - 执行任务类型: %current_task%
)

echo.

:: 执行实际的安全操作
call :safe_automation %mode% %cycle%

:: 等待一段时间（可调整）
timeout /t 15 /nobreak >nul

:: 每5个周期切换一下活动防止检测
if %cycle%==5 (
    echo 🔄 切换活动模式...
    set cycle=0
    if %mode%==5 (
        echo   混合模式继续...
    ) else (
        set /a mode=mode %% 4 + 1
        echo   切换到模式 %mode%
    )
    echo.
)

goto main_loop

:safe_automation
:: 安全自动化函数
:: 参数1: 模式，参数2: 周期

:: 模式1: 文档处理 - 创建测试文件
if %1==1 (
    if %2==1 (
        echo 📝 创建测试文档...
        echo 这是一个自动化创建的测试文档。 > test_doc_%time:~0,2%%time:~3,2%.txt
    )
)

:: 模式2: 浏览器 - 创建浏览记录
if %1==2 (
    if %2==1 (
        echo 🌐 模拟浏览器活动...
        echo 浏览器活动模拟完成。 > browser_log.txt
    )
)

:: 模式3: 文件管理 - 整理文件
if %1==3 (
    if %2==1 (
        echo 📁 整理测试文件...
        if exist test_doc_*.txt (
            echo 找到测试文件，进行整理...
        )
    )
)

:: 模式4: 系统维护 - 检查系统
if %1==4 (
    if %2==1 (
        echo ⚙️  检查系统状态...
        systeminfo | findstr /B /C:"OS 名称" /C:"系统类型" > system_check.txt
    )
)

:: 通用安全操作：移动鼠标
echo 🖱️  轻微移动鼠标位置...
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $pos=[System.Windows.Forms.Cursor]::Position; $pos.X+=5; [System.Windows.Forms.Cursor]::Position=$pos; Start-Sleep -Milliseconds 50; $pos.X-=5; [System.Windows.Forms.Cursor]::Position=$pos"

exit /b 0

:cleanup
echo.
echo ========================================
echo 🛑 自动化程序停止
echo ========================================
echo 总运行周期: %total_cycles%
echo 最后模式: %mode%
echo 开始时间: 记录在日志中
echo.
echo 创建的测试文件:
dir test_doc_*.txt 2>nul
dir browser_log.txt 2>nul
dir system_check.txt 2>nul
echo.
echo 感谢使用工作自动化助手
echo ========================================
pause
exit /b 0