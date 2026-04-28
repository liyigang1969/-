@echo off
echo 正在启动OpenClaw调试工具...
echo 如果出现错误，窗口将保持打开
echo.

REM 记录日志
set LOGFILE=E:\openclaw-data\.openclaw\workspace\debug_log.txt
echo Debug started: %date% %time% > "%LOGFILE%"

echo 步骤1: 检查Node.js >> "%LOGFILE%"
echo [1] 检查Node.js安装...
C:\nodejs\node.exe --version 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found >> "%LOGFILE%"
    echo ❌ Node.js未找到或无法运行
    goto :error
)
echo ✅ Node.js检查通过
echo Node.js check passed >> "%LOGFILE%"

echo.
echo 步骤2: 检查F盘数据目录 >> "%LOGFILE%"
echo [2] 检查F盘数据目录...
if not exist "F:\openclaw-data\.openclaw" (
    echo ERROR: F drive data directory missing >> "%LOGFILE%"
    echo ❌ F盘数据目录不存在
    goto :error
)
echo ✅ F盘数据目录存在
echo F drive directory exists >> "%LOGFILE%"

echo.
echo 步骤3: 尝试启动OpenClaw >> "%LOGFILE%"
echo [3] 尝试启动OpenClaw...
echo 注意: 如果出现"远程关闭，退出码1"，请记录错误信息
echo.

cd /d "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw" 2>&1
if errorlevel 1 (
    echo ERROR: Cannot change to OpenClaw directory >> "%LOGFILE%"
    echo ❌ 无法进入OpenClaw目录
    goto :error
)

echo 当前目录: %cd% >> "%LOGFILE%"
echo 正在启动OpenClaw... >> "%LOGFILE%"

REM 尝试启动OpenClaw，捕获所有输出
C:\nodejs\node.exe openclaw.mjs --data-dir "F:\openclaw-data\.openclaw" 2>&1
set EXIT_CODE=%errorlevel%

echo OpenClaw退出代码: %EXIT_CODE% >> "%LOGFILE%"

if %EXIT_CODE% equ 0 (
    echo ✅ OpenClaw启动成功
    echo OpenClaw started successfully >> "%LOGFILE%"
) else (
    echo ❌ OpenClaw启动失败，退出码: %EXIT_CODE%
    echo OpenClaw failed with exit code %EXIT_CODE% >> "%LOGFILE%"
)

goto :end

:error
echo.
echo ========================
echo 调试过程中发现错误
echo 详细日志已保存到: %LOGFILE%
echo ========================

:end
echo.
echo 调试完成！
echo 日志文件: %LOGFILE%
echo.
pause