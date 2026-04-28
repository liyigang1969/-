@echo off
echo ========================================
echo     F盘驱动问题全面诊断
echo ========================================
echo.

echo [1] 基本磁盘信息...
fsutil fsinfo volumeinfo F:
echo.

echo [2] 检查磁盘错误...
chkdsk F: /scan
echo.

echo [3] 检查磁盘空间...
for /f "tokens=3" %%a in ('dir F:\ /-c ^| findstr "可用字节"') do (
    set FREE_SPACE=%%a
)
for /f "tokens=3" %%a in ('dir F:\ /-c ^| findstr "字节" ^| findstr /v "可用"') do (
    set TOTAL_SPACE=%%a
)
echo 总空间: %TOTAL_SPACE%
echo 可用空间: %FREE_SPACE%
echo.

echo [4] 测试读写性能...
echo 测试写入...
echo Test write performance > F:\test_write.txt
if errorlevel 1 (
    echo ❌ 写入测试失败
) else (
    echo ✅ 写入测试通过
)

echo 测试读取...
type F:\test_write.txt >nul
if errorlevel 1 (
    echo ❌ 读取测试失败
) else (
    echo ✅ 读取测试通过
)

echo 测试删除...
del F:\test_write.txt >nul 2>&1
if errorlevel 1 (
    echo ❌ 删除测试失败
) else (
    echo ✅ 删除测试通过
)
echo.

echo [5] 检查文件系统完整性...
echo 尝试创建、写入、读取大文件...
echo Creating large test file... > F:\large_test.txt
for /l %%i in (1,1,1000) do (
    echo This is line %%i for filesystem test. >> F:\large_test.txt
)
if errorlevel 1 (
    echo ❌ 大文件创建失败
) else (
    echo ✅ 大文件创建成功
    for /f %%a in ('dir F:\large_test.txt ^| findstr "large_test.txt"') do (
        echo 文件大小: %%a
    )
    del F:\large_test.txt >nul 2>&1
    echo ✅ 大文件清理完成
)
echo.

echo [6] 检查OpenClaw目录访问...
if exist F:\openclaw-data\.openclaw (
    echo ✅ OpenClaw目录存在
    dir F:\openclaw-data\.openclaw /b | findstr "workspace memory" >nul
    if errorlevel 1 (
        echo ⚠️  目录结构可能不完整
    ) else (
        echo ✅ 关键目录存在
    )
    
    REM 测试配置文件读取
    if exist F:\openclaw-data\.openclaw\openclaw.json (
        echo ✅ 配置文件存在
        type F:\openclaw-data\.openclaw\openclaw.json | findstr "dataDir" >nul
        if errorlevel 1 (
            echo ⚠️  配置可能未正确设置
        ) else (
            echo ✅ 配置指向正确
        )
    )
) else (
    echo ❌ OpenClaw目录不存在
)
echo.

echo [7] 检查事件日志中的磁盘错误...
echo 正在检查系统事件日志...
REM 这里可以添加事件日志检查，但需要管理员权限
echo 需要管理员权限检查完整事件日志
echo.

echo [8] 设备管理器检查建议...
echo 请手动检查设备管理器:
echo 1. 按 Win + X，选择"设备管理器"
echo 2. 展开"磁盘驱动器"
echo 3. 检查F盘对应的设备是否有黄色感叹号
echo 4. 右键选择"属性"查看错误详情
echo.

echo ========================================
echo     诊断完成
echo ========================================
echo.
echo 如果发现以下问题:
echo   • 读写测试失败
echo   • chkdsk被拒绝访问
echo   • 设备管理器有错误
echo.
echo 建议解决方案:
echo 1. 重新插拔U盘
echo 2. 尝试不同USB端口
echo 3. 更新USB驱动程序
echo 4. 检查U盘物理损坏
echo 5. 备份数据后重新格式化
echo.
pause