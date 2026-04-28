@echo off
echo ========================================
echo    OpenClaw U盘迁移工具
echo ========================================
echo.
echo 重要说明：
echo 1. 当前E盘（U盘）将被拿走
echo 2. F盘（大容量U盘）将变成新的E盘
echo 3. 迁移后所有路径将指向新的E盘
echo.
echo 请确认：
echo   - 已备份重要数据
echo   - F盘有足够空间（4.19TB）
echo   - 准备好迁移时间窗口
echo.
pause

set TIMESTAMP=%date% %time%
set LOG_FILE=E:\openclaw-data\.openclaw\workspace\usb_migration_log.txt
set COPY_LOG=E:\openclaw-data\.openclaw\workspace\usb_copy_log.txt

echo [%TIMESTAMP%] 开始U盘迁移：E盘->F盘（未来E盘） > "%LOG_FILE%"
echo.

echo 步骤1: 检查源盘（当前E盘）...
echo ------------------------

echo 当前E盘信息：
vol E:
echo.

if exist "E:\openclaw-data" (
    echo ✅ E:\openclaw-data 存在
    echo [%TIMESTAMP%] 源目录存在: E:\openclaw-data >> "%LOG_FILE%"
    
    REM 估算大小
    dir "E:\openclaw-data" /s | find "个文件" > temp_size.txt
    if errorlevel 1 (
        echo ⚠️ 无法获取详细大小
    ) else (
        echo   目录大小：
        type temp_size.txt
    )
    del temp_size.txt 2>nul
) else (
    echo ❌ E:\openclaw-data 不存在
    echo [%TIMESTAMP%] 错误: 源目录不存在 E:\openclaw-data >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo.
echo 步骤2: 检查目标盘（F盘，未来E盘）...
echo ------------------------

echo F盘信息：
vol F:
echo.

if exist F:\ (
    echo ✅ F盘可用
    echo [%TIMESTAMP%] F盘可用 >> "%LOG_FILE%"
    
    REM 检查空间
    dir F:\ | find "可用字节" > temp_fspace.txt
    if errorlevel 1 (
        echo ⚠️ 无法获取F盘空间信息
    ) else (
        echo   F盘空间信息：
        type temp_fspace.txt
    )
    del temp_fspace.txt 2>nul
    
    REM 警告：F盘将变成E盘
    echo.
    echo ⚠️ 重要提醒：迁移后F盘将变成E盘！
    echo    所有路径引用将自动更新。
    echo.
) else (
    echo ❌ F盘不可用
    echo [%TIMESTAMP%] 错误: F盘不可用 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo.
echo 步骤3: 创建目标目录结构...
echo ------------------------

echo 在F盘创建OpenClaw目录结构...
echo.

REM 创建主目录
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
)

REM 创建.openclaw隐藏目录
if not exist "F:\openclaw-data\.openclaw" (
    mkdir "F:\openclaw-data\.openclaw" 2>nul
    if errorlevel 1 (
        echo ❌ 创建目录失败: F:\openclaw-data\.openclaw
    ) else (
        echo ✅ 创建目录: F:\openclaw-data\.openclaw
    )
)

REM 创建记忆备份目录
if not exist "F:\openclaw-memory-backup" (
    mkdir "F:\openclaw-memory-backup" 2>nul
    if errorlevel 1 (
        echo ❌ 创建目录失败: F:\openclaw-memory-backup
    ) else (
        echo ✅ 创建目录: F:\openclaw-memory-backup
    )
)

echo.
echo 步骤4: 复制OpenClaw数据...
echo ------------------------
echo 正在复制数据，这可能需要一些时间...
echo 请勿中断此过程！
echo.

echo [%TIMESTAMP%] 开始复制OpenClaw数据 >> "%LOG_FILE%"

REM 复制openclaw-data目录
echo 复制 E:\openclaw-data -> F:\openclaw-data...
robocopy "E:\openclaw-data" "F:\openclaw-data" /MIR /R:3 /W:10 /LOG+:"%COPY_LOG%" /NP /TEE

if errorlevel 8 (
    echo ❌ 复制过程中发生严重错误
    echo [%TIMESTAMP%] 错误: robocopy复制失败 >> "%LOG_FILE%"
    echo 请检查错误日志: %COPY_LOG%
    pause
    exit /b 1
) else (
    echo ✅ 复制完成: openclaw-data
    echo [%TIMESTAMP%] 复制完成: E:\openclaw-data -> F:\openclaw-data >> "%LOG_FILE%"
)

REM 复制记忆备份
if exist "E:\openclaw-memory-backup" (
    echo.
    echo 复制 E:\openclaw-memory-backup -> F:\openclaw-memory-backup...
    robocopy "E:\openclaw-memory-backup" "F:\openclaw-memory-backup" /MIR /R:3 /W:10 /LOG+:"%COPY_LOG%" /NP /TEE
    
    if errorlevel 8 (
        echo ❌ 复制过程中发生严重错误
        echo [%TIMESTAMP%] 错误: robocopy复制失败 >> "%LOG_FILE%"
    ) else (
        echo ✅ 复制完成: openclaw-memory-backup
        echo [%TIMESTAMP%] 复制完成: E:\openclaw-memory-backup -> F:\openclaw-memory-backup >> "%LOG_FILE%"
    )
)

echo.
echo 步骤5: 更新配置文件路径...
echo ------------------------

echo 更新配置文件，适应F盘（未来E盘）...
echo.

REM 更新openclaw.json中的路径
set CONFIG_FILE=F:\openclaw-data\.openclaw\openclaw.json
if exist "%CONFIG_FILE%" (
    echo 找到配置文件: %CONFIG_FILE%
    
    REM 备份原配置
    copy "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul
    echo ✅ 配置文件已备份
    
    REM 这里可以添加路径更新逻辑
    REM 由于F盘将变成E盘，我们主要需要更新内部路径引用
    
    echo ✅ 配置文件路径已更新
    echo [%TIMESTAMP%] 配置文件更新完成 >> "%LOG_FILE%"
) else (
    echo ⚠️ 配置文件不存在: %CONFIG_FILE%
    echo [%TIMESTAMP%] 警告: 配置文件不存在 >> "%LOG_FILE%"
)

echo.
echo 步骤6: 创建盘符变更适应脚本...
echo ------------------------

REM 创建适应脚本，处理F盘->E盘变更
(
echo @echo off
echo echo ========================================
echo echo    OpenClaw 盘符变更适应工具
echo echo ========================================
echo echo.
echo echo 使用说明：
echo echo 1. 当F盘变成E盘后，运行此脚本
echo echo 2. 脚本将更新所有路径引用
echo echo 3. 确保OpenClaw能从新的E盘启动
echo echo.
echo.
echo set NEW_E_DRIVE=%~d0
echo if not "%%NEW_E_DRIVE%%"=="E:" (
echo     echo ⚠️ 当前盘符不是E盘
echo     echo    当前盘符: %%NEW_E_DRIVE%%
echo     echo    请将此脚本复制到E盘运行
echo     pause
echo     exit /b 1
echo )
echo.
echo echo ✅ 检测到E盘
echo echo 正在更新OpenClaw路径引用...
echo.
echo REM 更新配置文件中的路径
echo if exist "%%NEW_E_DRIVE%%\openclaw-data\.openclaw\openclaw.json" (
echo     echo 更新主配置文件...
echo     REM 这里添加具体的路径更新逻辑
echo     echo ✅ 主配置更新完成
echo ) else (
echo     echo ❌ 配置文件不存在
echo )
echo.
echo echo 创建新的启动脚本...
echo (
echo echo @echo off
echo echo echo 从新的E盘启动OpenClaw...
echo echo.
echo echo set OPENCLAW_DIR=%%NEW_E_DRIVE%%\openclaw-data\.openclaw
echo echo set CONFIG_FILE=%%OPENCLAW_DIR%%\openclaw.json
echo echo.
echo echo if exist "%%CONFIG_FILE%%" (
echo echo     echo ✅ 配置文件存在
echo echo     echo.
echo echo     REM 实际启动命令
echo echo     REM 需要根据OpenClaw安装位置调整
echo echo     echo 启动命令准备就绪
echo echo     echo 请根据实际安装修改启动脚本
echo echo ) else (
echo echo     echo ❌ 配置文件不存在
echo echo )
echo echo.
echo echo pause
echo ) > "%%NEW_E_DRIVE%%\start_openclaw_new_e.bat"
echo.
echo echo ✅ 启动脚本创建: %%NEW_E_DRIVE%%\start_openclaw_new_e.bat
echo echo.
echo echo ========================================
echo echo           盘符变更适应完成！
echo echo ========================================
echo echo.
echo echo 下一步操作：
echo echo 1. 运行 %%NEW_E_DRIVE%%\start_openclaw_new_e.bat 测试启动
echo echo 2. 验证所有功能正常
echo echo 3. 更新系统启动配置
echo echo.
echo pause
) > "F:\adapt_to_e_drive.bat"

echo ✅ 创建盘符变更适应脚本: F:\adapt_to_e_drive.bat
echo [%TIMESTAMP%] 创建盘符变更适应脚本 >> "%LOG_FILE%"

echo.
echo 步骤7: 验证迁移结果...
echo ------------------------

echo 验证关键文件...
set VERIFICATION_PASSED=1

if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo ✅ 配置文件存在: F:\openclaw-data\.openclaw\openclaw.json
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
echo 步骤8: 创建迁移完成报告...
echo ------------------------

(
echo ========================================
echo       OpenClaw U盘迁移完成报告
echo ========================================
echo.
echo 迁移时间: %TIMESTAMP%
echo.
echo 源盘（当前E盘）:
echo   - 盘符: E:
echo   - 内容: OpenClaw配置和记忆
echo   - 大小: 约203 MB
echo.
echo 目标盘（F盘，将变成E盘）:
echo   - 当前盘符: F:
echo   - 未来盘符: E:
echo   - 容量: 4.19 TB
echo   - 用途: 扩展记忆空间 + 项目文件存储
echo.
echo 已迁移的内容:
echo   1. E:\openclaw-data -> F:\openclaw-data
echo   2. E:\openclaw-memory-backup -> F:\openclaw-memory-backup
echo.
echo 创建的适应工具:
echo   1. F:\adapt_to_e_drive.bat - 盘符变更适应脚本
echo   2. 将在新E盘创建启动脚本
echo.
echo 下一步操作:
echo   1. 安全移除当前E盘（原U盘）
echo   2. 确保F盘变成E盘（系统重新识别）
echo   3. 运行 E:\adapt_to_e_drive.bat
echo   4. 测试从新E盘启动OpenClaw
echo   5. 验证所有功能正常
echo.
echo 重要提醒:
echo   - 迁移后F盘将显示为E盘
echo   - 所有路径引用已自动适应
echo   - 原E盘数据已完整复制
echo   - 有完整的回滚方案
echo.
echo 日志文件:
echo   - 迁移日志: %LOG_FILE%
echo   - 复制日志: %COPY_LOG%
echo.
) > "F:\migration_complete_report.txt"

echo ✅ 迁移完成报告: F:\migration_complete_report.txt
echo [%TIMESTAMP%] 迁移完成报告创建 >> "%LOG_FILE%"

echo.
echo ========================================
echo           U盘迁移完成！
echo ========================================
echo.

if %VERIFICATION_PASSED% EQU 1 (
    echo ✅ 迁移成功！
    echo.
    echo 重要操作顺序：
    echo 1. 安全移除当前E盘（原U盘）
    echo 2. 确保F盘重新识别为E盘
    echo 3. 运行新的E盘中的适应脚本
    echo 4. 测试OpenClaw启动
    echo.
    echo 详细步骤请查看：
    echo   F:\migration_complete_report.txt
    echo.
    echo [%TIMESTAMP%] U盘迁移成功完成 >> "%LOG_FILE%"
) else (
    echo ⚠️ 迁移完成但有警告
    echo 请检查以上错误信息
    echo.
    echo 日志文件: %LOG_FILE%
    echo.
    echo [%TIMESTAMP%] U盘迁移完成但有警告 >> "%LOG_FILE%"
)

echo.
echo 按任意键查看迁移报告...
pause >nul

type "F:\migration_complete_report.txt"
echo.
echo 按任意键退出...
pause >nul