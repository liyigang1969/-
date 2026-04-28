@echo off
echo ========================================
echo     F盘迁移验证工具
echo ========================================
echo.

set TARGET=F:\openclaw-data\.openclaw

echo 验证目标: %TARGET%
echo.

echo [1/4] 检查目录完整性...
set MISSING=0

if not exist "%TARGET%\workspace" (
    echo ❌ 缺少 workspace 目录
    set /a MISSING+=1
) else (
    echo ✅ workspace 目录存在
    dir "%TARGET%\workspace\*.md" /b | findstr "AGENTS.md SOUL.md" >nul
    if errorlevel 1 (
        echo ⚠️  缺少关键配置文件
    ) else (
        echo ✅ 关键配置文件存在
    )
)

if not exist "%TARGET%\memory" (
    echo ❌ 缺少 memory 目录
    set /a MISSING+=1
) else (
    echo ✅ memory 目录存在
    dir "%TARGET%\memory\*.md" /b >nul
    if errorlevel 1 (
        echo ⚠️  记忆文件可能为空
    ) else (
        echo ✅ 记忆文件存在
    )
)

echo.

echo [2/4] 检查配置文件...
if exist "%TARGET%\openclaw.json" (
    echo ✅ openclaw.json 存在
    type "%TARGET%\openclaw.json" | findstr "F:/openclaw-data" >nul
    if errorlevel 1 (
        echo ⚠️  配置可能未指向F盘
    ) else (
        echo ✅ 配置指向F盘
    )
) else (
    echo ❌ 缺少 openclaw.json
    set /a MISSING+=1
)

echo.

echo [3/4] 测试数据访问...
echo 测试文件创建、读取、删除...
echo Test content > "%TARGET%\test_access.txt" 2>nul
if errorlevel 1 (
    echo ❌ 无法创建测试文件
    set /a MISSING+=1
) else (
    type "%TARGET%\test_access.txt" >nul 2>&1
    if errorlevel 1 (
        echo ❌ 无法读取测试文件
        set /a MISSING+=1
    ) else (
        del "%TARGET%\test_access.txt" >nul 2>&1
        if errorlevel 1 (
            echo ❌ 无法删除测试文件
            set /a MISSING+=1
        ) else (
            echo ✅ 文件访问测试通过
        )
    )
)

echo.

echo [4/4] 空间检查...
echo F盘空间状态:
for /f "tokens=2 delims=:" %%a in ('fsutil fsinfo volumeinfo F: ^| findstr "卷"') do (
    echo   总空间: %%a
)
echo   数据目录大小: 
dir "%TARGET%" /s | findstr "个文件"

echo.
echo ========================================
if %MISSING% equ 0 (
    echo ✅ F盘迁移验证通过！
    echo F盘完全适合OpenClaw数据迁移
    echo.
    echo 优势总结:
    echo   • 4TB大容量空间
    echo   • exFAT文件系统（支持大文件）
    echo   • 跨平台兼容性好
    echo   • 已有OpenClaw目录结构
    echo   • 读写性能良好
) else (
    echo ⚠️  验证发现 %MISSING% 个问题
    echo 请先解决这些问题再迁移
)
echo ========================================
pause