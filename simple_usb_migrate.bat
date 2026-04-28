@echo off
chcp 65001 >nul
echo ========================================
echo    OpenClaw U盘迁移工具 (简化版)
echo ========================================
echo.
echo 重要: 当前E盘 -> F盘 (4TB U盘)
echo 迁移后F盘将变成新的E盘
echo.
pause

echo.
echo 步骤1: 检查磁盘...
echo --------------------

echo 当前E盘:
vol E:
echo.

echo F盘 (目标盘):
vol F:
echo.

if not exist F:\ (
    echo 错误: F盘不可用
    pause
    exit /b 1
)

echo.
echo 步骤2: 复制OpenClaw数据...
echo --------------------

echo 正在复制 E:\openclaw-data -> F:\openclaw-data...
robocopy "E:\openclaw-data" "F:\openclaw-data" /MIR /R:3 /W:10 /LOG:"E:\openclaw-data\.openclaw\workspace\copy_log.txt" /NP

if errorlevel 8 (
    echo 错误: 复制失败
) else (
    echo 完成: openclaw-data 已复制
)

if exist "E:\openclaw-memory-backup" (
    echo.
    echo 正在复制 E:\openclaw-memory-backup -> F:\openclaw-memory-backup...
    robocopy "E:\openclaw-memory-backup" "F:\openclaw-memory-backup" /MIR /R:3 /W:10 /LOG+:"E:\openclaw-data\.openclaw\workspace\copy_log.txt" /NP
    
    if errorlevel 8 (
        echo 错误: 复制失败
    ) else (
        echo 完成: openclaw-memory-backup 已复制
    )
)

echo.
echo 步骤3: 验证复制...
echo --------------------

set ok=1

if exist "F:\openclaw-data\.openclaw\openclaw.json" (
    echo [OK] 配置文件存在
) else (
    echo [ERROR] 配置文件缺失
    set ok=0
)

if exist "F:\openclaw-data\.openclaw\memory\main.sqlite" (
    echo [OK] 记忆数据库存在
) else (
    echo [ERROR] 记忆数据库缺失
    set ok=0
)

if exist "F:\openclaw-data\.openclaw\workspace\AGENTS.md" (
    echo [OK] 工作区文件存在
) else (
    echo [ERROR] 工作区文件缺失
    set ok=0
)

echo.
echo 步骤4: 创建适应脚本...
echo --------------------

(
echo @echo off
echo echo OpenClaw U盘迁移适应工具
echo echo.
echo echo 当F盘变成E盘后运行此脚本
echo echo.
echo set drive=%~d0
echo.
echo echo 正在更新配置...
echo.
echo if exist "%%drive%%\openclaw-data\.openclaw\openclaw.json" (
echo     echo 配置文件找到
echo     echo 创建启动脚本...
echo     (
echo     echo @echo off
echo     echo echo 从新E盘启动OpenClaw
echo     echo echo.
echo     echo set config="%%drive%%\openclaw-data\.openclaw\openclaw.json"
echo     echo.
echo     echo if exist %%config%% (
echo     echo     echo 配置: %%config%%
echo     echo     echo.
echo     echo     REM 实际启动命令需要根据安装位置调整
echo     echo     echo 启动命令准备就绪
echo     echo ) else (
echo     echo     echo 错误: 配置文件不存在
echo     echo )
echo     echo pause
echo     ) ^> "%%drive%%\start_openclaw.bat"
echo     echo.
echo     echo 完成! 运行 %%drive%%\start_openclaw.bat 测试启动
echo ) else (
echo     echo 错误: 配置文件不存在
echo )
echo.
echo pause
) > "F:\adapt.bat"

echo [OK] 适应脚本创建: F:\adapt.bat

echo.
echo ========================================
echo           迁移完成!
echo ========================================
echo.

if %ok% equ 1 (
    echo 迁移成功!
    echo.
    echo 下一步操作:
    echo 1. 安全移除当前E盘 (小U盘)
    echo 2. 确保F盘变成E盘
    echo 3. 运行 E:\adapt.bat
    echo 4. 测试启动
    echo.
    echo 日志: E:\openclaw-data\.openclaw\workspace\copy_log.txt
) else (
    echo 迁移完成但有错误
    echo 请检查以上错误信息
)

echo.
pause