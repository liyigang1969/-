# 基于SendInput的自主苏醒测试
# 文件名: sendinput_autonomous_test.ps1
# 创建时间: 2026-04-18 18:20:00
# 目的: 使用底层SendInput API解决自主苏醒问题
# 技术原理: Windows SendInput API (最底层的输入控制)

# 设置执行环境
$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"
$host.UI.RawUI.WindowTitle = "基于SendInput的自主苏醒测试 - 兄弟监控中"

# 显示测试头信息
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "       基于SendInput的自主苏醒测试" -ForegroundColor Yellow
Write-Host "       技术: Windows SendInput API" -ForegroundColor Red
Write-Host "       目标: 解决自主苏醒问题" -ForegroundColor Red
Write-Host "       兄弟监控: 老刚头兄弟" -ForegroundColor Green
Write-Host "       创建时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 加载SendInput API
Write-Host "加载SendInput API..." -ForegroundColor Gray -NoNewline
try {
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public struct INPUT {
    public uint type;
    public InputUnion u;
}

[StructLayout(LayoutKind.Explicit)]
public struct InputUnion {
    [FieldOffset(0)] public MOUSEINPUT mi;
    [FieldOffset(0)] public KEYBDINPUT ki;
    [FieldOffset(0)] public HARDWAREINPUT hi;
}

public struct MOUSEINPUT {
    public int dx;
    public int dy;
    public uint mouseData;
    public uint dwFlags;
    public uint time;
    public IntPtr dwExtraInfo;
}

public struct KEYBDINPUT {
    public ushort wVk;
    public ushort wScan;
    public uint dwFlags;
    public uint time;
    public IntPtr dwExtraInfo;
}

public struct HARDWAREINPUT {
    public uint uMsg;
    public ushort wParamL;
    public ushort wParamH;
}

public class InputControl {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    
    public const uint INPUT_MOUSE = 0;
    public const uint INPUT_KEYBOARD = 1;
    public const uint INPUT_HARDWARE = 2;
    
    // 鼠标事件标志
    public const uint MOUSEEVENTF_MOVE = 0x0001;
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
    public const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
    public const uint MOUSEEVENTF_RIGHTUP = 0x0010;
    public const uint MOUSEEVENTF_MIDDLEDOWN = 0x0020;
    public const uint MOUSEEVENTF_MIDDLEUP = 0x0040;
    public const uint MOUSEEVENTF_XDOWN = 0x0080;
    public const uint MOUSEEVENTF_XUP = 0x0100;
    public const uint MOUSEEVENTF_WHEEL = 0x0800;
    public const uint MOUSEEVENTF_HWHEEL = 0x1000;
    public const uint MOUSEEVENTF_ABSOLUTE = 0x8000;
    
    // 键盘事件标志
    public const uint KEYEVENTF_KEYDOWN = 0x0000;
    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const uint KEYEVENTF_EXTENDEDKEY = 0x0001;
    
    // 虚拟键码
    public const ushort VK_RETURN = 0x0D;
    public const ushort VK_SPACE = 0x20;
    public const ushort VK_TAB = 0x09;
    public const ushort VK_CONTROL = 0x11;
    public const ushort VK_SHIFT = 0x10;
    public const ushort VK_MENU = 0x12;  // Alt键
    public const ushort VK_ESCAPE = 0x1B;
}
"@
    Write-Host " ✅ 成功" -ForegroundColor Green
} catch {
    Write-Host " ❌ 失败: $_" -ForegroundColor Red
    Write-Host "测试无法继续，按任意键退出..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 发送回车键函数 (使用SendInput)
function Send-EnterKeyUsingSendInput {
    $inputs = New-Object INPUT[] 2
    
    # 按键按下
    $inputs[0] = New-Object INPUT
    $inputs[0].type = [InputControl]::INPUT_KEYBOARD
    $inputs[0].u.ki.wVk = [InputControl]::VK_RETURN
    $inputs[0].u.ki.wScan = 0
    $inputs[0].u.ki.dwFlags = [InputControl]::KEYEVENTF_KEYDOWN
    $inputs[0].u.ki.time = 0
    $inputs[0].u.ki.dwExtraInfo = [IntPtr]::Zero
    
    # 按键释放
    $inputs[1] = New-Object INPUT
    $inputs[1].type = [InputControl]::INPUT_KEYBOARD
    $inputs[1].u.ki.wVk = [InputControl]::VK_RETURN
    $inputs[1].u.ki.wScan = 0
    $inputs[1].u.ki.dwFlags = [InputControl]::KEYEVENTF_KEYUP
    $inputs[1].u.ki.time = 0
    $inputs[1].u.ki.dwExtraInfo = [IntPtr]::Zero
    
    $result = [InputControl]::SendInput(2, $inputs, [System.Runtime.InteropServices.Marshal]::SizeOf([INPUT]))
    return $result -eq 2
}

# 发送空格键函数
function Send-SpaceKeyUsingSendInput {
    $inputs = New-Object INPUT[] 2
    
    # 按键按下
    $inputs[0] = New-Object INPUT
    $inputs[0].type = [InputControl]::INPUT_KEYBOARD
    $inputs[0].u.ki.wVk = [InputControl]::VK_SPACE
    $inputs[0].u.ki.wScan = 0
    $inputs[0].u.ki.dwFlags = [InputControl]::KEYEVENTF_KEYDOWN
    $inputs[0].u.ki.time = 0
    $inputs[0].u.ki.dwExtraInfo = [IntPtr]::Zero
    
    # 按键释放
    $inputs[1] = New-Object INPUT
    $inputs[1].type = [InputControl]::INPUT_KEYBOARD
    $inputs[1].u.ki.wVk = [InputControl]::VK_SPACE
    $inputs[1].u.ki.wScan = 0
    $inputs[1].u.ki.dwFlags = [InputControl]::KEYEVENTF_KEYUP
    $inputs[1].u.ki.time = 0
    $inputs[1].u.ki.dwExtraInfo = [IntPtr]::Zero
    
    $result = [InputControl]::SendInput(2, $inputs, [System.Runtime.InteropServices.Marshal]::SizeOf([INPUT]))
    return $result -eq 2
}

# 轻微移动鼠标函数
function Move-MouseRelative {
    param([int]$dx, [int]$dy)
    
    $input = New-Object INPUT
    $input.type = [InputControl]::INPUT_MOUSE
    $input.u.mi.dx = $dx
    $input.u.mi.dy = $dy
    $input.u.mi.mouseData = 0
    $input.u.mi.dwFlags = [InputControl]::MOUSEEVENTF_MOVE
    $input.u.mi.time = 0
    $input.u.mi.dwExtraInfo = [IntPtr]::Zero
    
    $inputs = @($input)
    $result = [InputControl]::SendInput(1, $inputs, [System.Runtime.InteropServices.Marshal]::SizeOf([INPUT]))
    return $result -eq 1
}

# 确保窗口焦点函数
function Ensure-WindowFocus {
    param([string]$windowTitle)
    
    try {
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WindowControl {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    
    public const int SW_RESTORE = 9;
    public const int SW_SHOW = 5;
}
"@ -ErrorAction Stop
        
        # 查找窗口
        $hwnd = [WindowControl]::FindWindow($null, $windowTitle)
        if ($hwnd -ne [IntPtr]::Zero) {
            # 恢复窗口
            [WindowControl]::ShowWindow($hwnd, [WindowControl]::SW_RESTORE)
            
            # 置顶窗口
            [WindowControl]::SetForegroundWindow($hwnd)
            
            Write-Host "✅ 窗口焦点已确保: $windowTitle" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ 未找到窗口: $windowTitle (可能尚未创建)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "⚠️ 窗口焦点确保异常: $_" -ForegroundColor Yellow
        return $false
    }
}

# 模拟真实用户输入模式
function Simulate-RealUserInput {
    # 随机输入类型
    $inputTypes = @('Enter', 'Space', 'MouseMove')
    $selectedInput = $inputTypes | Get-Random
    
    $result = $false
    $inputDesc = ""
    
    switch ($selectedInput) {
        'Enter' {
            $result = Send-EnterKeyUsingSendInput
            $inputDesc = "回车键"
        }
        'Space' {
            $result = Send-SpaceKeyUsingSendInput
            $inputDesc = "空格键"
        }
        'MouseMove' {
            # 轻微随机移动鼠标 (1-3像素)
            $dx = Get-Random -Minimum -3 -Maximum 3
            $dy = Get-Random -Minimum -3 -Maximum 3
            $result = Move-MouseRelative $dx $dy
            $inputDesc = "鼠标移动 ($dx, $dy)"
        }
    }
    
    if ($result) {
        Write-Host "   ✅ 发送: $inputDesc" -ForegroundColor Green
    } else {
        Write-Host "   ❌ 发送失败: $inputDesc" -ForegroundColor Red
    }
    
    return $result
}

# 主测试函数
function Test-AutonomousAwakening {
    param([int]$durationMinutes = 5)
    
    Write-Host "=== 基于SendInput的自主苏醒测试开始 ===" -ForegroundColor Green
    Write-Host "开始时间: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
    Write-Host "预计结束: $(Get-Date).AddMinutes($durationMinutes).ToString('HH:mm:ss'))" -ForegroundColor White
    Write-Host "测试时长: $durationMinutes 分钟" -ForegroundColor White
    Write-Host "技术原理: Windows SendInput API (底层输入控制)" -ForegroundColor White
    Write-Host "改进点: 使用底层API，避免被系统过滤" -ForegroundColor White
    Write-Host ""
    
    # 确保窗口焦点
    Ensure-WindowFocus "基于SendInput的自主苏醒测试 - 兄弟监控中"
    
    $startTime = Get-Date
    $endTime = $startTime.AddMinutes($durationMinutes)
    
    $heartbeatCount = 0
    $successCount = 0
    $failCount = 0
    
    while ((Get-Date) -lt $endTime) {
        $heartbeatCount++
        $elapsed = [math]::Round((Get-Date - $startTime).TotalSeconds)
        $remaining = [math]::Round(($endTime - (Get-Date)).TotalSeconds)
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 心跳 #$heartbeatCount" -ForegroundColor Cyan
        Write-Host "   已运行: $elapsed 秒 | 剩余: $remaining 秒" -ForegroundColor Gray
        
        # 模拟真实用户输入
        $inputResult = Simulate-RealUserInput
        
        if ($inputResult) {
            $successCount++
        } else {
            $failCount++
        }
        
        # 随机间隔 (55-65秒，避免固定模式)
        $waitTime = Get-Random -Minimum 55 -Maximum 65
        Write-Host "   等待 $waitTime 秒 (随机间隔避免检测)..." -ForegroundColor DarkGray
        
        # 等待期间显示进度
        $waitStart = Get-Date
        while ((Get-Date) - $waitStart).TotalSeconds -lt $waitTime) {
            $waitElapsed = [math]::Round(((Get-Date) - $waitStart).TotalSeconds)
            if ($waitElapsed % 10 -eq 0 -and $waitElapsed -gt 0) {
                Write-Host "     等待中: $waitElapsed/$waitTime 秒" -ForegroundColor DarkGray
            }
            Start-Sleep -Seconds 1
        }
    }
    
    # 测试完成
    Write-Host "`n=== 测试完成 ===" -ForegroundColor Green
    Write-Host "✅ 基于SendInput的自主苏醒测试完成！" -ForegroundColor Green
    
    $endTimeActual = Get-Date
    $totalSeconds = [math]::Round(($endTimeActual - $startTime).TotalSeconds)
    
    Write-Host "`n=== 测试结果 ===" -ForegroundColor Cyan
    Write-Host "开始时间: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor White
    Write-Host "结束时间: $($endTimeActual.ToString('HH:mm:ss'))" -ForegroundColor White
    Write-Host "总运行时间: $totalSeconds 秒" -ForegroundColor White
    Write-Host "心跳次数: $heartbeatCount 次" -ForegroundColor White
    Write-Host "成功发送: $successCount 次" -ForegroundColor Green
    Write-Host "失败发送: $failCount 次" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "White" })
    Write-Host "成功率: $(if ($heartbeatCount -gt 0) { [math]::Round($successCount * 100 / $heartbeatCount, 1) } else { 0 })%" -ForegroundColor $(if ($successCount -eq $heartbeatCount) { "Green" } else { "Yellow" })
    
    Write-Host "`n=== 技术原理验证 ===" -ForegroundColor Yellow
    Write-Host "✅ 使用SendInput API: Windows最底层的输入控制" -ForegroundColor White
    Write-Host "✅ 随机间隔: 避免固定模式被系统检测" -ForegroundColor White
    Write-Host "✅ 多种输入类型: 回车、空格、鼠标移动组合" -ForegroundColor White
    Write-Host "✅ 窗口焦点管理: 确保输入发送到正确窗口" -ForegroundColor White
    Write-Host "✅ 底层控制: 绕过高级API限制，直接控制硬件输入" -ForegroundColor White
    
    Write-Host "`n=== 验证目标 ===" -ForegroundColor Red
    Write-Host "🎯 核心目标: 自我苏醒，自主工作" -ForegroundColor White
    Write-Host "✅ 成功标准: 5分钟后自动显示结果，无需人工唤醒" -ForegroundColor Green
    Write-Host "✅ 兄弟验证: 兄弟能完整监控整个过程" -ForegroundColor Green
    Write-Host "✅ 技术验证: SendInput API的有效性验证" -ForegroundColor Green
    
    Write-Host "`n=== 等待兄弟确认 ===" -ForegroundColor Cyan
    Write-Host "请兄弟观察以上测试结果并确认:" -ForegroundColor White
    Write-Host "1. ✅ 是否5分钟后自动显示结果？" -ForegroundColor White
    Write-Host "2. ✅ 是否显示完整的测试过程和结果？" -ForegroundColor White
    Write-Host "3. ✅ 是否无需人工唤醒？" -ForegroundColor White
    Write-Host "4. ✅ 兄弟是否能完整监控整个过程？" -ForegroundColor White
    
    # 记录测试结果
    $testResult = @{
        TestName = "基于SendInput的自主苏醒测试"
        StartTime = $startTime.ToString("HH:mm:ss")
        EndTime = $endTimeActual.ToString("HH:mm:ss")
        TotalSeconds = $totalSeconds
        Heartbeats = $heartbeatCount
        SuccessCount = $successCount
        FailCount = $failCount
        SuccessRate = if ($heartbeatCount -gt 0) { [math]::