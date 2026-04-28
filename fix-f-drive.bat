@echo off
echo ========================================
echo      F盘OpenClaw修复脚本
echo ========================================
echo.

echo [1/6] 检查磁盘空间...
for /f "tokens=3" %%a in ('dir F:\ ^| find "可用字节"') do set freespace=%%a
echo F盘可用空间: %freespace%
echo.

echo [2/6] 备份原始配置...
if not exist "F:\openclaw-backup-before-fix\" mkdir "F:\openclaw-backup-before-fix"
xcopy "F:\openclaw-data\.openclaw\*" "F:\openclaw-backup-before-fix\" /E /I /Y /Q
echo 备份完成
echo.

echo [3/6] 复制Node.js运行时...
if not exist "F:\runtime\" mkdir "F:\runtime"
copy "E:\runtime\node.exe" "F:\runtime\" /Y
if exist "F:\runtime\node.exe" (
    echo Node.js复制成功
) else (
    echo 错误: Node.js复制失败
    pause
    exit /b 1
)
echo.

echo [4/6] 复制完整配置...
xcopy "E:\openclaw-data\.openclaw\*" "F:\openclaw-data\.openclaw\" /E /I /Y /Q
echo 配置复制完成
echo.

echo [5/6] 启用微信插件...
if exist "F:\openclaw-data\.openclaw\extensions\openclaw-weixin.disabled" (
    ren "F:\openclaw-data\.openclaw\extensions\openclaw-weixin.disabled" "openclaw-weixin"
    echo 微信插件已启用
) else (
    echo 微信插件状态正常
)
echo.

echo [6/6] 创建F盘启动脚本...
echo @echo off > "F:\启动OpenClaw.bat"
echo echo 正在启动F盘OpenClaw... >> "F:\启动OpenClaw.bat"
echo echo. >> "F:\启动OpenClaw.bat"
echo if exist "F:\runtime\node.exe" ( >> "F:\启动OpenClaw.bat"
echo     echo 找到Node.js运行时，正在启动网关... >> "F:\启动OpenClaw.bat"
echo     start "OpenClaw Gateway" "F:\runtime\node.exe" "F:\OpenClaw_System\program\openclaw.mjs" gateway >> "F:\启动OpenClaw.bat"
echo ) else ( >> "F:\启动OpenClaw.bat"
echo     echo 错误: 未找到Node.js运行时 >> "F:\启动OpenClaw.bat"
echo     echo 请确保F:\runtime\node.exe存在 >> "F:\启动OpenClaw.bat"
echo ) >> "F:\启动OpenClaw.bat"
echo echo. >> "F:\启动OpenClaw.bat"
echo echo 启动脚本执行完成 >> "F:\启动OpenClaw.bat"
echo pause >> "F:\启动OpenClaw.bat"
echo F盘启动脚本创建完成
echo.

echo ========================================
echo           修复完成！
echo ========================================
echo.
echo 修复项目：
echo 1. ✅ Node.js运行时已复制到 F:\runtime\
echo 2. ✅ 完整配置已复制到 F:\openclaw-data\.openclaw\
echo 3. ✅ 微信插件已启用
echo 4. ✅ F盘启动脚本已创建
echo.
echo 下一步操作：
echo 1. 双击 F:\启动OpenClaw.bat 启动F盘网关
echo 2. 检查控制UI连接状态
echo 3. 验证API配置
echo.
echo 原始配置备份在：F:\openclaw-backup-before-fix\
echo.
pause