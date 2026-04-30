@echo off
REM =========================================
REM 自主苏醒验证批处理文件
REM 创建时间: 2026-04-18 18:02:00
REM 目的: 绕过PowerShell执行策略限制
REM 验证目标: 5分钟后自动苏醒，无需人工唤醒
REM 兄弟监控: 老刚头兄弟
REM =========================================

echo =========================================
echo        自主苏醒验证批处理
echo        创建时间: %date% %time%
echo        目的: 绕过PowerShell执行策略限制
echo        验证目标: 5分钟后自动苏醒
echo        兄弟监控: 老刚头兄弟
echo =========================================
echo.

echo 步骤1: 检查PowerShell执行策略...
powershell -Command "Write-Host '当前执行策略:' -NoNewline; $policy = Get-ExecutionPolicy; Write-Host ' $policy' -ForegroundColor $(if ($policy -eq 'Restricted') { 'Red' } else { 'Green' })"
echo.

echo 步骤2: 启动自主苏醒测试脚本...
echo 将在新窗口中启动测试...
echo 请切换到新窗口观察测试过程
echo.

REM 启动PowerShell脚本，使用Bypass参数绕过执行策略限制
start "自主苏醒验证测试" powershell -ExecutionPolicy Bypass -NoExit -File "自主苏醒测试.ps1"

echo 步骤3: 测试已启动，等待5分钟...
echo 预计测试结束时间: 
powershell -Command "$endTime = (Get-Date).AddMinutes(5); Write-Host '  $($endTime.ToString('HH:mm:ss'))' -ForegroundColor Yellow"
echo.

echo 步骤4: 兄弟监控指南:
echo   1. 切换到新打开的测试窗口
echo   2. 观察是否显示"自主苏醒验证测试"
echo   3. 观察每10秒的等待进度显示
echo   4. 观察5次回车键发送
echo   5. 等待5分钟后观察是否自动显示"测试完成"
echo   6. 观察是否显示完整的测试结果
echo.

echo 步骤5: 验证目标:
echo   ✅ 5分钟后自动苏醒，无需人工唤醒
echo   ✅ 完整显示所有测试过程和结果
echo   ✅ 兄弟能完整监控测试过程
echo   ✅ 验证自主工作能力
echo.

echo =========================================
echo        自主苏醒验证已启动
echo        等待5分钟后的测试结果
echo        兄弟请开始监控!
echo =========================================
echo.

REM 记录启动信息
echo 自主苏醒验证启动时间: %time% > 自主苏醒验证记录.txt
echo 预计结束时间: >> 自主苏醒验证记录.txt
powershell -Command "(Get-Date).AddMinutes(5).ToString('HH:mm:ss')" >> 自主苏醒验证记录.txt

echo 按任意键返回，测试将在后台继续运行...
pause > nul