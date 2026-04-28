@echo off
echo ========================================
echo     修复OpenClaw"退出码1"错误
echo ========================================
echo.

echo [1/6] 检查Node.js版本...
C:\nodejs\node.exe --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js不可用
    echo 请确保C:\nodejs\node.exe存在
    pause
    exit /b 1
)
for /f "delims=" %%v in ('C:\nodejs\node.exe --version') do (
    echo ✅ Node.js版本: %%v
)
echo.

echo [2/6] 检查F盘数据目录...
if exist F:\openclaw-data\.openclaw (
    echo ✅ 数据目录存在
    dir F:\openclaw-data\.openclaw /b | findstr "workspace openclaw.json" >nul
    if errorlevel 1 (
        echo ⚠️  目录可能不完整
    )
) else (
    echo ❌ 数据目录不存在
    pause
    exit /b 1
)
echo.

echo [3/6] 检查配置文件...
if exist F:\openclaw-data\.openclaw\openclaw.json (
    echo ✅ 配置文件存在
    type F:\openclaw-data\.openclaw\openclaw.json | findstr "dataDir.*F:/openclaw-data" >nul
    if errorlevel 1 (
        echo ⚠️  配置未指向F盘
        echo 正在修复配置...
        (
            echo {
            echo   "storage": {
            echo     "dataDir": "F:/openclaw-data/.openclaw",
            echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
            echo   }
            echo }
        ) > F:\openclaw-data\.openclaw\openclaw.json.fixed
        move /y F:\openclaw-data\.openclaw\openclaw.json.fixed F:\openclaw-data\.openclaw\openclaw.json
        echo ✅ 配置修复完成
    )
) else (
    echo ❌ 配置文件缺失
    echo 创建默认配置...
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   }
        echo }
    ) > F:\openclaw-data\.openclaw\openclaw.json
    echo ✅ 配置创建完成
)
echo.

echo [4/6] 检查端口占用...
echo 检查端口3000是否被占用...
netstat -ano | findstr :3000 >nul
if errorlevel 1 (
    echo ✅ 端口3000可用
) else (
    echo ⚠️  端口3000被占用
    echo 尝试使用其他端口...
    
    REM 修改配置使用其他端口
    if exist F:\openclaw-data\.openclaw\openclaw.json (
        type F:\openclaw-data\.openclaw\openclaw.json | findstr "port" >nul
        if errorlevel 1 (
            echo 添加端口配置...
            powershell -Command "(Get-Content 'F:\openclaw-data\.openclaw\openclaw.json' | ConvertFrom-Json) | Add-Member -NotePropertyName 'gateway' -NotePropertyValue @{port=3001} -Force | ConvertTo-Json -Depth 10 | Set-Content 'F:\openclaw-data\.openclaw\openclaw.json'"
            echo ✅ 改为使用端口3001
        )
    )
)
echo.

echo [5/6] 测试简化启动...
echo 测试基本功能...
cd /d C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw
C:\nodejs\node.exe openclaw.mjs --version >nul 2>&1
if errorlevel 1 (
    echo ❌ OpenClaw基本测试失败
    echo 可能程序文件损坏
) else (
    for /f "delims=" %%v in ('C:\nodejs\node.exe openclaw.mjs --version 2^>nul') do (
        echo ✅ OpenClaw版本: %%v
    )
)
echo.

echo [6/6] 尝试诊断模式启动...
echo 以诊断模式启动OpenClaw...
echo 注意: 按Ctrl+C停止
echo.
cd /d C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw
C:\nodejs\node.exe openclaw.mjs --data-dir "F:\openclaw-data\.openclaw" --log-level debug
echo.

echo ========================================
echo     修复步骤完成
echo ========================================
echo.
echo 如果仍有"退出码1"错误，可能是:
echo 1. Node.js版本不兼容 (需要>=22.16.0)
echo 2. F盘权限问题 (exFAT限制)
echo 3. 配置文件严重错误
echo 4. OpenClaw程序文件损坏
echo.
echo 建议下一步:
echo 1. 下载最新版OpenClaw到F盘
echo 2. 更新Node.js到最新版
echo 3. 检查系统事件日志
echo 4. 尝试以管理员身份运行
echo.
pause