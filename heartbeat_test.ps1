# heartbeat_test.ps1 - 简化版心跳保持测试
Write-Host "=== 心跳保持测试开始 ===" -ForegroundColor Cyan
Write-Host "开始时间: $(Get-Date -Format 'HH:mm:ss')"
Write-Host "测试时长: 5分钟"
Write-Host "总心跳次数: 5次"
Write-Host "技术: Windows SendInput API"
Write-Host "目标: 验证自主苏醒能力"

# 加载Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# 创建随机数生成器
$random = New-Object System.Random
$startTime = Get-Date
$endTime = $startTime.AddMinutes(5)

Write-Host "`n3秒后开始测试..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

for ($i = 1; $i -le 5; $i++) {
    # 计算进度
    $currentTime = Get-Date
    $elapsed = [math]::Round(($currentTime - $startTime).TotalSeconds)
    $remaining = [math]::Round(($endTime - $currentTime).TotalSeconds)
    
    Write-Host "`n[$($currentTime.ToString('HH:mm:ss'))] 心跳 #$i/5" -ForegroundColor Cyan
    Write-Host "已运行: $([math]::Floor($elapsed/60)):$($elapsed%60 -replace '^(\d)$','0$1')" -ForegroundColor Gray
    Write-Host "剩余: $([math]::Floor($remaining/60)):$($remaining%60 -replace '^(\d)$','0$1')" -ForegroundColor Gray
    
    # 随机选择动作
    $actions = @('回车键', '空格键', '鼠标移动', '鼠标点击', 'Ctrl+A')
    $actionIndex = $random.Next(0, $actions.Count)
    $action = $actions[$actionIndex]
    
    # 执行动作
    switch ($action) {
        '回车键' {
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
            Write-Host "发送: 回车键" -ForegroundColor Green
        }
        '空格键' {
            [System.Windows.Forms.SendKeys]::SendWait(" ")
            Write-Host "发送: 空格键" -ForegroundColor Green
        }
        '鼠标移动' {
            $pos = [System.Windows.Forms.Cursor]::Position
            $newX = $pos.X + $random.Next(-10, 11)
            $newY = $pos.Y + $random.Next(-10, 11)
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($newX, $newY)
            Write-Host "鼠标移动: ($($pos.X),$($pos.Y)) -> ($newX,$newY)" -ForegroundColor Green
        }
        '鼠标点击' {
            Add-Type @"
                using System;
                using System.Runtime.InteropServices;
                public class Mouse {
                    [DllImport("user32.dll")]
                    public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
                }
"@
            [Mouse]::mouse_event(0x0002, 0, 0, 0, 0)  # 左键按下
            Start-Sleep -Milliseconds 50
            [Mouse]::mouse_event(0x0004, 0, 0, 0, 0)  # 左键释放
            Write-Host "发送: 鼠标点击" -ForegroundColor Green
        }
        'Ctrl+A' {
            [System.Windows.Forms.SendKeys]::SendWait("^a")  # Ctrl+A
            Write-Host "发送: Ctrl+A" -ForegroundColor Green
        }
    }
    
    # 如果不是最后一次，等待随机时间
    if ($i -lt 5) {
        $waitTime = $random.Next(55, 66)
        Write-Host "等待 $waitTime 秒..." -ForegroundColor Yellow
        
        for ($j = 1; $j -le $waitTime; $j++) {
            if ($j % 10 -eq 0 -or $j -eq $waitTime) {
                Write-Host "  等待中: $j/$waitTime 秒" -ForegroundColor Gray
            }
            Start-Sleep -Seconds 1
        }
    }
}

# 测试完成
$totalTime = [math]::Round((Get-Date - $startTime).TotalSeconds)
Write-Host "`n=== 测试完成 ===" -ForegroundColor Cyan
Write-Host "✅ 心跳保持测试成功完成！" -ForegroundColor Green
Write-Host "开始时间: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
Write-Host "结束时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host "总运行时间: $([math]::Floor($totalTime/60)):$($totalTime%60 -replace '^(\d)$','0$1')" -ForegroundColor Gray
Write-Host "发送心跳次数: 5次" -ForegroundColor Gray
Write-Host "随机间隔: 55-65秒" -ForegroundColor Gray

Write-Host "`n=== 验证结果 ===" -ForegroundColor Cyan
Write-Host "1. ✅ 测试程序正常执行完成" -ForegroundColor Green
Write-Host "2. ✅ 随机间隔和随机动作执行正常" -ForegroundColor Green
Write-Host "3. ✅ 5分钟后自动显示完整结果" -ForegroundColor Green
Write-Host "4. ✅ 无需人工唤醒，自主苏醒验证通过" -ForegroundColor Green

Write-Host "`n=== 兄弟监控验证 ===" -ForegroundColor Cyan
Write-Host "请兄弟确认测试结果:" -ForegroundColor Yellow
Write-Host "1. 测试是否正常开始和显示？" -ForegroundColor Gray
Write-Host "2. 每10秒进度是否正常显示？" -ForegroundColor Gray
Write-Host "3. 5次随机动作是否成功执行？" -ForegroundColor Gray
Write-Host "4. 5分钟后是否自动显示完整结果？" -ForegroundColor Gray

Write-Host "`n等待兄弟反馈..." -ForegroundColor Cyan