@echo off
echo ========================================
echo     继续未完成的迁移
echo ========================================
echo 检测到昨天迁移未完成，继续迁移剩余部分
echo.

set SOURCE=E:\openclaw-data\.openclaw
set TARGET=F:\openclaw-data\.openclaw
set LOG=F:\migration_continue.log

echo 开始时间: %date% %time% > "%LOG%"
echo 源目录: %SOURCE% >> "%LOG%"
echo 目标目录: %TARGET% >> "%LOG%"
echo. >> "%LOG%"

echo [1/5] 分析迁移状态...
echo 分析迁移状态... >> "%LOG%"

REM 检查哪些目录需要迁移
set MIGRATE_LIST=

if not exist "%TARGET%\memory\*.md" (
    echo ⚠️  memory目录需要迁移
    set MIGRATE_LIST=memory %MIGRATE_LIST%
    echo memory目录需要迁移 >> "%LOG%"
) else (
    echo ✅ memory目录已存在
    echo memory目录已存在 >> "%LOG%"
)

dir "%SOURCE%\memory\*.md" /b >nul 2>&1
if errorlevel 1 (
    echo ℹ️  源memory目录无文件
    echo 源memory目录无文件 >> "%LOG%"
) else (
    echo ℹ️  源memory目录有文件
    echo 源memory目录有文件 >> "%LOG%"
)

echo.

echo [2/5] 备份当前状态...
echo 备份当前状态... >> "%LOG%"
set BACKUP=F:\openclaw-data-backup-continue
mkdir "%BACKUP%" 2>nul
xcopy "%TARGET%" "%BACKUP%" /E /I /H /Y /Q
if errorlevel 1 (
    echo ⚠️  备份过程中有警告
    echo 备份过程中有警告 >> "%LOG%"
) else (
    echo ✅ 备份完成: %BACKUP%
    echo 备份完成: %BACKUP% >> "%LOG%"
)

echo.

echo [3/5] 迁移缺失的数据...
echo 迁移缺失的数据... >> "%LOG%"

REM 迁移memory目录
if "%MIGRATE_LIST%" NEQ "" (
    echo 正在迁移缺失的目录: %MIGRATE_LIST%
    echo 正在迁移缺失的目录: %MIGRATE_LIST% >> "%LOG%"
    
    for %%d in (%MIGRATE_LIST%) do (
        echo.
        echo 迁移 %%d 目录...
        echo 迁移 %%d 目录... >> "%LOG%"
        
        if exist "%SOURCE%\%%d" (
            xcopy "%SOURCE%\%%d" "%TARGET%\%%d" /E /I /H /Y
            if errorlevel 1 (
                echo ❌ %%d 目录迁移失败
                echo %%d 目录迁移失败 >> "%LOG%"
            ) else (
                echo ✅ %%d 目录迁移完成
                echo %%d 目录迁移完成 >> "%LOG%"
                
                REM 验证迁移
                dir "%TARGET%\%%d" /b >nul 2>&1
                if errorlevel 1 (
                    echo ⚠️  %%d 目录验证失败
                    echo %%d 目录验证失败 >> "%LOG%"
                ) else (
                    echo ✅ %%d 目录验证通过
                    echo %%d 目录验证通过 >> "%LOG%"
                )
            )
        ) else (
            echo ℹ️  源目录不存在: %%d
            echo 源目录不存在: %%d >> "%LOG%"
        )
    )
) else (
    echo ℹ️  无需迁移，所有目录已存在
    echo 无需迁移，所有目录已存在 >> "%LOG%"
)

echo.

echo [4/5] 同步更新文件...
echo 同步更新文件... >> "%LOG%"

REM 检查并更新配置文件
if exist "%TARGET%\openclaw.json" (
    echo 检查配置文件...
    type "%TARGET%\openclaw.json" | findstr "F:/openclaw-data" >nul
    if errorlevel 1 (
        echo ⚠️  配置文件未指向F盘，正在更新...
        echo 配置文件未指向F盘，正在更新... >> "%LOG%"
        (
            echo {
            echo   "storage": {
            echo     "dataDir": "F:/openclaw-data/.openclaw",
            echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
            echo   },
            echo   "gateway": {
            echo     "host": "0.0.0.0",
            echo     "port": 3000
            echo   }
            echo }
        ) > "%TARGET%\openclaw.json.new"
        move /y "%TARGET%\openclaw.json.new" "%TARGET%\openclaw.json" >nul
        echo ✅ 配置文件更新完成
        echo 配置文件更新完成 >> "%LOG%"
    ) else (
        echo ✅ 配置文件已正确指向F盘
        echo 配置文件已正确指向F盘 >> "%LOG%"
    )
) else (
    echo ℹ️  创建新配置文件
    echo 创建新配置文件 >> "%LOG%"
    (
        echo {
        echo   "storage": {
        echo     "dataDir": "F:/openclaw-data/.openclaw",
        echo     "workspace": "F:/openclaw-data/.openclaw/workspace"
        echo   }
        echo }
    ) > "%TARGET%\openclaw.json"
    echo ✅ 新配置文件创建完成
    echo 新配置文件创建完成 >> "%LOG%"
)

echo.

echo [5/5] 验证迁移结果...
echo 验证迁移结果... >> "%LOG%"

set VERIFY_PASS=1

echo 检查关键目录:
echo 检查关键目录: >> "%LOG%"

if exist "%TARGET%\workspace\AGENTS.md" (
    echo ✅ workspace/AGENTS.md 存在
    echo workspace/AGENTS.md 存在 >> "%LOG%"
) else (
    echo ❌ workspace/AGENTS.md 缺失
    echo workspace/AGENTS.md 缺失 >> "%LOG%"
    set VERIFY_PASS=0
)

if exist "%TARGET%\workspace\SOUL.md" (
    echo ✅ workspace/SOUL.md 存在
    echo workspace/SOUL.md 存在 >> "%LOG%"
) else (
    echo ❌ workspace/SOUL.md 缺失
    echo workspace/SOUL.md 缺失 >> "%LOG%"
    set VERIFY_PASS=0
)

if exist "%TARGET%\memory\*.md" (
    echo ✅ memory目录有文件
    echo memory目录有文件 >> "%LOG%"
) else (
    echo ⚠️  memory目录为空
    echo memory目录为空 >> "%LOG%"
)

if exist "%TARGET%\openclaw.json" (
    echo ✅ openclaw.json 存在
    echo openclaw.json 存在 >> "%LOG%"
) else (
    echo ❌ openclaw.json 缺失
    echo openclaw.json 缺失 >> "%LOG%"
    set VERIFY_PASS=0
)

echo.
echo 结束时间: %date% %time% >> "%LOG%"
echo 迁移日志: %LOG% >> "%LOG%"

echo.
echo ========================================
if %VERIFY_PASS% equ 1 (
    echo ✅ 迁移继续完成！
    echo.
    echo 摘要:
    echo   • 已备份当前状态到: %BACKUP%
    echo   • 迁移了缺失的目录: %MIGRATE_LIST%
    echo   • 更新了配置文件
    echo   • 验证了关键文件
    echo.
    echo 下一步:
    echo   1. 测试运行: F:\start_openclaw_f.bat
    echo   2. 验证功能完整性
    echo   3. 检查迁移日志: %LOG%
) else (
    echo ⚠️  迁移完成但有警告
    echo.
    echo 请检查:
    echo   1. 缺失的文件
    echo   2. 迁移日志: %LOG%
    echo   3. 可能需要手动修复
)
echo ========================================
echo 详细日志已保存到: %LOG%
pause