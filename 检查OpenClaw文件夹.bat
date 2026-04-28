@echo off
echo 正在检查OpenClaw文件夹的文件数量...
echo.

set BASE_DIR=C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw

echo 检查目录: %BASE_DIR%
echo.

REM 检查总文件数
dir "%BASE_DIR%" /s /b /a-d | find /c /v "" > temp_count.txt
set /p TOTAL_FILES=<temp_count.txt
del temp_count.txt

echo 总文件数: %TOTAL_FILES%
echo.

REM 检查各子目录
echo 各子目录文件数量:
echo -------------------------
for %%d in (node_modules dist docs skills assets) do (
    if exist "%BASE_DIR%\%%d" (
        dir "%BASE_DIR%\%%d" /s /b /a-d 2>nul | find /c /v "" > temp_count.txt
        set /p COUNT=<temp_count.txt
        del temp_count.txt
        echo %%d: %COUNT% 个文件
    )
)

echo.
echo 主要目录内容:
echo -------------------------
dir "%BASE_DIR%\dist" 2>nul && echo dist - 编译后的文件
dir "%BASE_DIR%\docs" 2>nul && echo docs - 文档文件
dir "%BASE_DIR%\skills" 2>nul && echo skills - 技能文件
dir "%BASE_DIR%\node_modules" 2>nul && echo node_modules - 依赖包
dir "%BASE_DIR%\assets" 2>nul && echo assets - 资源文件

echo.
pause