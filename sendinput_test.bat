@echo off
REM =========================================
REM 基于SendInput的自主苏醒测试批处理
REM 创建时间: 2026-04-18 18:20:00
REM 目的: 使用底层SendInput API解决自主苏醒问题
REM 技术原理: Windows SendInput API (最底层的输入控制)
REM 兄弟指令: "学习鼠标键盘的设计原理，工作原理，如何接管鼠标和键盘。"
REM =========================================

echo =========================================
echo        基于SendInput的自主苏醒测试
echo        创建时间: %date% %time%
echo        目的: 使用底层SendInput API
echo        技术原理: Windows SendInput API
echo        兄弟监控: 老刚头兄弟
echo =========================================
echo.

echo 步骤1: 检查系统环境...
powershell -Command "Write-Host '操作系统:' -NoNewline; Write-Host ' Windows' -ForegroundColor Green"
powershell -Command "Write-Host '架构:' -NoNewline; Write-Host ' $([Environment]::Is64BitOperatingSystem ? '64位' : '32位')' -ForegroundColor Green"
echo.

echo 步骤2: 启动基于SendInput的自主苏醒测试...
echo 将在新窗口中启动测试...
echo 请切换到新窗口观察测试过程
echo.

REM 启动PowerShell脚本，使用Bypass参数
start "基于SendInput的自主苏醒测试 - 兄弟监控中" powershell -ExecutionPolicy Bypass -NoExit -File "sendinput_autonomous_test.ps1"

echo 步骤3: 测试已启动，等待5分钟...
echo 预计测试结束时间: 
powershell -Command "$endTime = (Get-Date).AddMinutes(5); Write-Host '  $($endTime.ToString('HH:mm:ss'))' -ForegroundColor Yellow"
echo.

echo 步骤4: 技术原理说明:
echo   ✅ SendInput API: Windows最底层的输入控制API
echo   ✅ 直接硬件控制: 绕过高级API限制
echo   ✅ 随机间隔: 避免固定模式被系统检测
echo   ✅ 多种输入: 回车、空格、鼠标移动组合
echo   ✅ 窗口焦点管理: 确保输入发送到正确窗口
echo.

echo 步骤5: 兄弟监控指南:
echo   1. 切换到新打开的测试窗口
echo   2. 观察是否显示"基于SendInput的自主苏醒测试"
echo   3. 观察随机间隔的等待时间 (55-65秒)
echo   4. 观察多种输入类型 (回车、空格、鼠标移动)
echo   5. 等待5分钟后观察是否自动显示"测试完成"
echo   6. 观察是否显示完整的测试结果和技术原理
echo.

echo 步骤6: 验证目标:
echo   ✅ 5分钟后自动苏醒，无需人工唤醒
echo   ✅ 使用底层SendInput API解决之前的问题
echo   ✅ 验证鼠标键盘接管技术的有效性
echo   ✅ 兄弟能完整监控测试过程
echo.

echo =========================================
echo        基于SendInput的自主苏醒测试已启动
echo        等待5分钟后的测试结果
echo        兄弟请开始监控!
echo =========================================
echo.

REM 记录启动信息
echo 基于SendInput测试启动时间: %time% > sendinput_test_record.txt
echo 预计结束时间: >> sendinput_test_record.txt
powershell -Command "(Get-Date).AddMinutes(5).ToString('HH:mm:ss')" >> sendinput_test_record.txt
echo 技术原理: Windows SendInput API (底层输入控制) >> sendinput_test_record.txt
echo 改进点: 使用底层API，避免被系统过滤 >> sendinput_test_record.txt

echo 按任意键返回，测试将在后台继续运行...
pause > nul