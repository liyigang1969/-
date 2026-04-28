@echo off
echo === Windows系统信息 ===
systeminfo | findstr /B /C:"OS 名称" /C:"OS 版本" /C:"系统类型"
echo.
echo === 磁盘信息 ===
wmic logicaldisk get size,freespace,caption
echo.
echo === Node.js检查 ===
where node >nul 2>&1
if %errorlevel% equ 0 (
    echo Node.js已安装
    node --version
) else (
    echo Node.js未安装或不在PATH中
)
echo.
echo === OpenClaw检查 ===
if exist "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\" (
    echo OpenClaw安装目录存在
) else (
    echo OpenClaw安装目录不存在
)
echo.
if exist "E:\openclaw-data\.openclaw\" (
    echo OpenClaw数据目录存在
) else (
    echo OpenClaw数据目录不存在
)
echo.
echo === 系统文件检查 ===
echo 运行系统文件检查器...
sfc /verifyonly
pause