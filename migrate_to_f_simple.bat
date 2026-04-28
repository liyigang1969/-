@echo off
echo ========================================
echo    OpenClaw 迁移到F盘工具 (简化版)
echo ========================================
echo.

set TIMESTAMP=%date% %time%
set LOG_FILE=E:\openclaw-data\.openclaw\workspace\migration_simple_log.txt
set COPY_LOG=E:\openclaw-data\.openclaw\workspace\copy_simple_log.txt

echo [%TIMESTAMP%] 开始OpenClaw迁移到F盘 > "%LOG_FILE%"
echo.

echo 步骤1: 检查源目录...
echo ------------------------

if exist "E:\openclaw-data" (
    echo ✅ E:\openclaw-data 存在
    echo [%TIMESTAMP%] 源目录存在: E:\openclaw-data >> "%LOG_FILE%"
) else (
    echo ❌ E:\openclaw-data 不存在
    echo [%TIMESTAMP%] 错误: 源目录不存在 E:\openclaw-data >> "%LOG_FILE%"
    pause
    exit /b 1
)

if exist "E:\openclaw-memory-backup" (
    echo ✅ E:\openclaw-memory-backup 存在
    echo [%TIMESTAMP%] 备份目录存在: E:\openclaw-memory-backup >> "%LOG_FILE%"
) else (
    echo ⚠️ E:\openclaw-memory-backup 不存在
    echo [%TIMESTAMP%] 警告: 备份目录不存在 E:\openclaw-memory-backup >> "%LOG_FILE%"
)

echo.
echo 步骤2: 检查F盘...
echo ------------------------

if exist F:\ (
    echo ✅ F盘可用
    echo [%TIMESTAMP%] F盘可用 >> "%LOG_FILE%"
    
    REM 检查F盘空间（简单检查）
    dir F:\ | find "可用字节" > temp_space.txt
    if errorlevel 1 (
        echo ⚠️ 无法获取F盘空间信息
    ) else (
        echo   空间信息:
        type temp_space.txt
    )
    del temp_space.txt 2>nul
) else (
    echo ❌ F盘不可用
    echo [%TIMESTAMP%] 错误: F盘不可用 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo.
echo 步骤3: 创建目标目录...
echo ------------------------

if not exist "F:\openclaw-data" (
    mkdir "F:\openclaw-data" 2>nul
    if errorlevel 1 (
        echo ❌ 创建目录失败: F:\openclaw-data
        echo [%TIMESTAMP%] 错误: 创建目录失败 F:\openclaw-data >> "%LOG_FILE%"
        pause
        exit /b 1
    ) else (
        echo ✅ 创建目录: F:\openclaw-data
        echo [%TIMESTAMP%] 创建目录: F:\openclaw-data >> "%LOG_FILE%"
    )
) else (
    echo ⚠️ 目录已存在: F:\openclaw-data
    echo [%TIMESTAMP%] 目录已存在: F:\openclaw-data >> "%LOG_FILE%"
)

if not exist "F:\openclaw-memory-backup" (
    mkdir "F:\openclaw-memory-backup" 2>nul
    if errorlevel 1 (
        echo ❌ 创建目录失败: F:\openclaw-memory-backup
        echo [%TIMESTAMP%] 错误: 创建目录失败 F:\openclaw-memory-backup >> "%LOG_FILE%"
    ) else (
        echo ✅ 创建目录: F:\openclaw-memory-backup
        echo [%TIMESTAMP%] 创建目录: F:\openclaw-memory-backup >> "%LOG_FILE%"
    )
) else (
    echo ⚠️ 目录已存在: F:\openclaw-memory-backup
    echo [%TIMESTAMP%] 目录已存在: F:\openclaw-memory-backup >> "%LOG_FILE%"
)

echo.
echo 步骤4: 复制文件到F盘...
echo ------------------------
echo 这可能需要几分钟时间，请耐心等待...
echo.

echo [%TIMESTAMP%] 开始复制文件 >> "%LOG_FILE%"
echo 复制日志: %COPY_LOG% >> "%LOG_FILE%"

echo 正在复制 E:\openclaw-data -> F:\openclaw-data...
robocopy "E:\openclaw-data" "F:\openclaw-data" /MIR /R:3 /W:10 /LOG+:"%COPY_LOG%" /NP

if errorlevel 8 (
    echo ❌ 复制过程中发生错误
    echo [%TIMESTAMP%] 错误: robocopy复制失败 >> "%LOG_FILE%"
) else (
    echo ✅ 复制完成: openclaw-data
    echo [%TIMESTAMP%] 复制完成: E:\openclaw-data -> F:\openclaw-data >> "%LOG_FILE%"
)

if exist "E:\openclaw-memory-backup" (
    echo.
    echo 正在复制 E:\openclaw-memory-backup -> F:\openclaw-memory-backup...
    robocopy "E:\openclaw-memory-backup" "F:\openclaw-memory-backup" /MIR /R:3 /W:10 /LOG+:"%COPY_LOG%" /NP
    
    if errorlevel 8 (
        echo ❌ 复制过程中发生错误
        echo [%TIMESTAMP%] 错误: robocopy复制失败 >> "%LOG_FILE%"
    ) else (
        echo ✅ 复制完成: openclaw-memory-backup
        echo [%TIMESTAMP%] 复制完成: E:\openclaw-memory-backup -> F:\openclaw-memory-backup >> "%LOG_FILE%"
    )
)

echo.
echo 步骤5: 验证复制结果...
echo ------------------------

set VERIFICATION_PASSED=1

echo 检查关键文件...
if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo ✅ 配置文件存在
) else (
    echo ❌ 配置文件缺失
    set VERIFICATION_PASSED=0
)

if exist "F:\openclaw-data\.openclaw\memory\main.sqlite" (
    echo ✅ 记忆数据库存在
) else (
    echo ❌ 记忆数据库缺失
    set VERIFICATION_PASSED=0
)

if exist "F:\openclaw-data\.openclaw\workspace\AGENTS.md" (
    echo ✅ 工作区文件存在
) else (
    echo ❌ 工作区文件缺失
    set VERIFICATION_PASSED=0
)

echo.
echo 步骤6: 创建F盘启动脚本...
echo ------------------------

(
echo @echo off
echo echo 从F盘启动OpenClaw...
echo echo.
echo.
echo set OPENCLAW_DIR=F:\openclaw-data\.openclaw
echo set CONFIG_FILE=%%OPENCLAW_DIR%%\openclaw.json
echo.
echo echo 配置目录: %%OPENCLAW_DIR%%
echo echo 配置文件: %%CONFIG_FILE%%
echo echo.
echo.
echo if exist "%%CONFIG_FILE%%" (
echo     echo ✅ 配置文件存在
echo     echo 正在启动OpenClaw...
echo     echo.
echo     REM 启动命令示例:
echo     REM cd /d "C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw"
echo     REM node openclaw.mjs --config "%%CONFIG_FILE%%"
echo     echo.
echo     echo 启动命令已准备就绪
echo     echo 请根据实际安装位置修改启动命令
echo ) else (
echo     echo ❌ 配置文件不存在
echo     echo 请检查迁移是否完成
echo )
echo.
echo pause
) > "F:\start_openclaw_from_f.bat"

echo ✅ 启动脚本创建: F:\start_openclaw_from_f.bat
echo [%TIMESTAMP%] 启动脚本创建: F:\start_openclaw_from_f.bat >> "%LOG_FILE%"

echo.
echo ========================================
echo           迁移完成总结
echo ========================================
echo.

if %VERIFICATION_PASSED% EQU 1 (
    echo ✅ 迁移成功!
    echo.
    echo 已迁移的内容:
    echo 1. E:\openclaw-data -> F:\openclaw-data
    echo 2. E:\openclaw-memory-backup -> F:\openclaw-memory-backup
    echo.
    echo 下一步操作:
    echo 1. 测试从F盘启动: 运行 F:\start_openclaw_from_f.bat
    echo 2. 验证功能完整性
    echo 3. 更新OpenClaw实际启动配置
    echo 4. 清理E盘旧文件（确认F盘运行正常后）
    echo.
    echo 日志文件:
    echo   - 迁移日志: %LOG_FILE%
    echo   - 复制日志: %COPY_LOG%
    echo.
    echo [%TIMESTAMP%] 迁移成功完成 >> "%LOG_FILE%"
) else (
    echo ⚠️ 迁移完成但有警告
    echo 请检查以上错误信息
    echo.
    echo 日志文件: %LOG_FILE%
    echo.
    echo [%TIMESTAMP%] 迁移完成但有警告 >> "%LOG_FILE%"
)

echo.
echo 按任意键退出...
pause >nul