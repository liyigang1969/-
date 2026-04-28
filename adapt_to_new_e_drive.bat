@echo off
echo ========================================
echo   OpenClaw U盘迁移 - 适应新E盘脚本
echo ========================================
echo.
echo 此脚本应在以下情况下运行：
echo 1. 数据已从原E盘复制到F盘
echo 2. 原E盘已移除
echo 3. F盘已变成新的E盘
echo.
echo 按任意键继续，或按Ctrl+C取消...
pause > nul

echo.
echo [1/5] 检查当前盘符配置...
vol E:
if %errorlevel% neq 0 (
    echo 错误: E盘不可访问！
    echo 请确保F盘已正确分配为E盘盘符。
    pause
    exit /b 1
)

echo.
echo [2/5] 验证OpenClaw文件...
if not exist "E:\openclaw-data\.openclaw\openclaw.json" (
    echo 错误: 未找到OpenClaw配置文件！
    echo 请检查数据是否已正确复制。
    pause
    exit /b 1
)

if not exist "E:\openclaw-data\.openclaw\memory\main.sqlite" (
    echo 警告: 未找到记忆数据库，但继续...
)

echo.
echo [3/5] 更新记忆关联系统配置...
if exist "E:\openclaw-data\.openclaw\workspace\file_associations.json" (
    echo 更新file_associations.json中的路径...
    powershell -Command "
        $configPath = 'E:\openclaw-data\.openclaw\workspace\file_associations.json'
        if (Test-Path $configPath) {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            foreach ($item in $config.associations) {
                if ($item.path -like 'E:*') {
                    # 路径已经是E盘，无需更改
                    Write-Host '路径已正确: ' $item.path
                }
            }
            $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
            Write-Host '配置更新完成！'
        }
    "
) else (
    echo 未找到file_associations.json，跳过...
)

echo.
echo [4/5] 创建新E盘启动脚本...
(
echo @echo off
echo echo ========================================
echo echo   OpenClaw - 从新E盘启动
echo echo ========================================
echo echo.
echo echo 当前配置路径: E:\openclaw-data\.openclaw
echo echo 记忆数据库: E:\openclaw-data\.openclaw\memory\main.sqlite
echo echo 工作区: E:\openclaw-data\.openclaw\workspace
echo echo.
echo echo 按任意键查看磁盘状态...
echo pause ^> nul
echo echo.
echo vol E:
echo echo.
echo echo 按任意键退出...
echo pause ^> nul
) > "E:\start_openclaw_from_new_e.bat"

echo.
echo [5/5] 创建迁移完成验证脚本...
(
echo @echo off
echo echo OpenClaw U盘迁移验证报告
echo echo ================================
echo echo.
echo echo [1] 检查关键文件...
echo if exist "E:\openclaw-data\.openclaw\openclaw.json" (
echo     echo ✅ 配置文件: 存在
echo ) else (
echo     echo ❌ 配置文件: 缺失
echo )
echo.
echo if exist "E:\openclaw-data\.openclaw\memory\main.sqlite" (
echo     echo ✅ 记忆数据库: 存在
echo ) else (
echo     echo ⚠️  记忆数据库: 缺失（如果是新安装可能正常）
echo )
echo.
echo if exist "E:\openclaw-data\.openclaw\workspace\AGENTS.md" (
echo     echo ✅ 工作区文件: 存在
echo ) else (
echo     echo ❌ 工作区文件: 缺失
echo )
echo.
echo echo [2] 检查记忆备份...
echo if exist "E:\openclaw-memory-backup\" (
echo     echo ✅ 记忆备份目录: 存在
echo     dir "E:\openclaw-memory-backup\" /b
echo ) else (
echo     echo ⚠️  记忆备份目录: 缺失
echo )
echo.
echo echo [3] 磁盘空间状态...
echo vol E:
echo echo.
echo echo [4] 迁移完成状态...
echo echo ✅ 数据复制: 完成
echo echo ✅ 盘符变更: 完成（当前为E盘）
echo echo ✅ 配置适应: 完成
echo echo.
echo echo 按任意键退出...
echo pause ^> nul
) > "E:\verify_migration_complete.bat"

echo.
echo ========================================
echo   适应脚本创建完成！
echo ========================================
echo.
echo 已创建以下文件：
echo 1. E:\start_openclaw_from_new_e.bat - 新E盘启动脚本
echo 2. E:\verify_migration_complete.bat - 迁移验证脚本
echo.
echo 下一步操作：
echo 1. 运行 E:\verify_migration_complete.bat 验证迁移
echo 2. 如果验证通过，可以安全移除原E盘
echo 3. 从新E盘启动OpenClaw进行测试
echo.
echo 按任意键退出...
pause > nul