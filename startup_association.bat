@echo off
echo ========================================
echo     OpenClaw 记忆关联启动脚本
echo ========================================
echo.

set LOG_FILE=E:\openclaw-data\.openclaw\workspace\startup_log.txt
set CONFIG_FILE=E:\openclaw-data\.openclaw\workspace\file_associations.json
set TIMESTAMP=%date% %time%

echo [%TIMESTAMP%] 开始OpenClaw记忆关联启动 > "%LOG_FILE%"
echo.

echo 正在加载关联配置文件...
if exist "%CONFIG_FILE%" (
    echo ✅ 关联配置文件存在
    echo [%TIMESTAMP%] 加载关联配置文件: %CONFIG_FILE% >> "%LOG_FILE%"
) else (
    echo ❌ 关联配置文件不存在
    echo [%TIMESTAMP%] 错误: 关联配置文件不存在 >> "%LOG_FILE%"
)

echo.
echo 正在检查关联文件...
echo.

REM 检查核心安装
set CORE_DIR=C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw
if exist "%CORE_DIR%" (
    echo ✅ 核心安装目录: %CORE_DIR%
    echo [%TIMESTAMP%] 核心安装目录存在: %CORE_DIR% >> "%LOG_FILE%"
    
    REM 检查关键文件
    if exist "%CORE_DIR%\package.json" (
        echo   ✓ package.json 存在
    ) else (
        echo   ✗ package.json 缺失
    )
    
    if exist "%CORE_DIR%\openclaw.mjs" (
        echo   ✓ openclaw.mjs 存在
    ) else (
        echo   ✗ openclaw.mjs 缺失
    )
) else (
    echo ❌ 核心安装目录不存在
    echo [%TIMESTAMP%] 错误: 核心安装目录不存在 >> "%LOG_FILE%"
)

echo.

REM 检查配置目录
set CONFIG_DIR=E:\openclaw-data\.openclaw
if exist "%CONFIG_DIR%" (
    echo ✅ 配置目录: %CONFIG_DIR%
    echo [%TIMESTAMP%] 配置目录存在: %CONFIG_DIR% >> "%LOG_FILE%"
    
    if exist "%CONFIG_DIR%\openclaw.json" (
        echo   ✓ openclaw.json 存在
    ) else (
        echo   ✗ openclaw.json 缺失
    )
    
    if exist "%CONFIG_DIR%\memory\main.sqlite" (
        echo   ✓ 记忆数据库存在
    ) else (
        echo   ✗ 记忆数据库缺失
    )
) else (
    echo ❌ 配置目录不存在
    echo [%TIMESTAMP%] 错误: 配置目录不存在 >> "%LOG_FILE%"
)

echo.

REM 检查记忆备份
set BACKUP_DIR=E:\openclaw-memory-backup
if exist "%BACKUP_DIR%" (
    echo ✅ 记忆备份目录: %BACKUP_DIR%
    echo [%TIMESTAMP%] 记忆备份目录存在: %BACKUP_DIR% >> "%LOG_FILE%"
    
    if exist "%BACKUP_DIR%\memory-database\main.sqlite" (
        echo   ✓ 备份记忆数据库存在
    ) else (
        echo   ✗ 备份记忆数据库缺失
    )
    
    if exist "%BACKUP_DIR%\restore_memory.bat" (
        echo   ✓ 恢复工具存在
    ) else (
        echo   ✗ 恢复工具缺失
    )
) else (
    echo ⚠️ 记忆备份目录不存在
    echo [%TIMESTAMP%] 警告: 记忆备份目录不存在 >> "%LOG_FILE%"
)

echo.

REM 检查资源包
set PACKAGE_DIR=D:\OpenClaw_Packages
if exist "%PACKAGE_DIR%" (
    echo ✅ 资源包目录: %PACKAGE_DIR%
    echo [%TIMESTAMP%] 资源包目录存在: %PACKAGE_DIR% >> "%LOG_FILE%"
) else (
    echo ⚠️ 资源包目录不存在
    echo [%TIMESTAMP%] 信息: 资源包目录不存在 >> "%LOG_FILE%"
)

echo.
echo 正在创建记忆索引...
echo [%TIMESTAMP%] 开始创建记忆索引 >> "%LOG_FILE%"

REM 创建简单的记忆索引文件
set INDEX_FILE=E:\openclaw-data\.openclaw\workspace\memory_index.txt
(
echo # OpenClaw 记忆索引
echo # 生成时间: %TIMESTAMP%
echo.
echo ## 关联文件系统
echo 1. 核心安装: %CORE_DIR%
echo 2. 配置目录: %CONFIG_DIR%
echo 3. 记忆备份: %BACKUP_DIR%
echo 4. 资源包: %PACKAGE_DIR%
echo.
echo ## 关键文件状态
) > "%INDEX_FILE%"

if exist "%CORE_DIR%\package.json" (
    for /f "usebackq tokens=2 delims=:" %%a in (`findstr "version" "%CORE_DIR%\package.json"`) do (
        echo 核心版本: %%a >> "%INDEX_FILE%"
    )
)

echo 配置文件: %CONFIG_DIR%\openclaw.json >> "%INDEX_FILE%"
echo 记忆数据库: %CONFIG_DIR%\memory\main.sqlite >> "%INDEX_FILE%"
echo 工作区文件: %CONFIG_DIR%\workspace\ >> "%INDEX_FILE%"

echo.
echo ✅ 记忆索引创建完成: %INDEX_FILE%
echo [%TIMESTAMP%] 记忆索引创建完成: %INDEX_FILE% >> "%LOG_FILE%"

echo.
echo ========================================
echo           启动关联完成!
echo ========================================
echo.
echo 已关联的文件系统:
echo 1. 核心安装 - 运行OpenClaw
echo 2. 配置目录 - 个人配置和记忆
echo 3. 记忆备份 - 安全备份
echo 4. 资源包 - 额外资源
echo.
echo 使用命令:
echo   !files    - 查看关联文件
echo   !backup   - 执行备份
echo   !restore  - 恢复记忆
echo   !info     - 系统信息
echo.
echo 详细日志: %LOG_FILE%
echo 记忆索引: %INDEX_FILE%
echo.
echo [%TIMESTAMP%] OpenClaw记忆关联启动完成 >> "%LOG_FILE%"
echo.

pause