# PowerShell Windows Forms自动化原理学习笔记

## 📚 学习目标
深入理解PowerShell Windows Forms自动化的底层原理，掌握键盘鼠标模拟、窗口控制、对话框处理等关键技术。

## 🔍 技术背景

### 1. Windows Forms简介
**Windows Forms**是.NET Framework中的一个GUI类库，用于创建Windows桌面应用程序。虽然主要用于创建GUI应用，但其底层API也可以用于自动化控制。

### 2. PowerShell与.NET集成
PowerShell深度集成.NET Framework，可以直接调用.NET类库，包括Windows Forms。

## 🛠️ 核心组件分析

### 1. System.Windows.Forms程序集
```powershell
# 加载Windows Forms程序集
Add-Type -AssemblyName System.Windows.Forms
```

#### 关键类：
- **SendKeys**: 发送键盘输入
- **Cursor**: 鼠标控制
- **Screen**: 屏幕信息
- **Control**: 窗口控件基础类
- **MessageBox**: 消息对话框

### 2. SendKeys类原理分析

#### 功能：
模拟键盘输入，可以发送单个按键、组合键、特殊键等。

#### 核心方法：
```powershell
# 发送按键
[System.Windows.Forms.SendKeys]::SendWait("Hello{ENTER}")

# 发送组合键
[System.Windows.Forms.SendKeys]::SendWait("^c")  # Ctrl+C
```

#### 特殊键代码：
| 键 | 代码 | 说明 |
|----|------|------|
| **ENTER** | `{ENTER}` | 回车键 |
| **TAB** | `{TAB}` | Tab键 |
| **ESC** | `{ESC}` | Escape键 |
| **BACKSPACE** | `{BACKSPACE}` | 退格键 |
| **DELETE** | `{DELETE}` | 删除键 |
| **F1-F12** | `{F1}`-`{F12}` | 功能键 |
| **Ctrl** | `^` | 控制键 |
| **Alt** | `%` | Alt键 |
| **Shift** | `+` | Shift键 |

#### 底层原理：
1. **Windows消息机制**: 通过SendInput API发送键盘消息
2. **消息队列**: 将按键消息放入系统消息队列
3. **焦点窗口**: 发送到当前焦点窗口
4. **同步执行**: SendWait会等待按键处理完成

### 3. Cursor类原理分析

#### 功能：
控制鼠标位置和状态。

#### 核心属性：
```powershell
# 获取当前鼠标位置
$currentPos = [System.Windows.Forms.Cursor]::Position
Write-Host "X: $($currentPos.X), Y: $($currentPos.Y)"

# 设置鼠标位置
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(100, 200)
```

#### 底层原理：
1. **SetCursorPos API**: 调用Windows API设置光标位置
2. **屏幕坐标**: 使用屏幕坐标系（左上角为0,0）
3. **立即生效**: 设置后立即移动鼠标

### 4. 鼠标点击模拟原理

#### 使用Windows API：
```powershell
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Mouse {
        [DllImport("user32.dll")]
        public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint cButtons, uint dwExtraInfo);
    }
"@

# 鼠标事件常量
$MOUSEEVENTF_LEFTDOWN = 0x02
$MOUSEEVENTF_LEFTUP = 0x04
$MOUSEEVENTF_RIGHTDOWN = 0x08
$MOUSEEVENTF_RIGHTUP = 0x10

# 左键点击
[Mouse]::mouse_event($MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)  # 按下
[Mouse]::mouse_event($MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)    # 释放
```

#### mouse_event参数：
- **dwFlags**: 事件类型（按下、释放、移动等）
- **dx, dy**: 相对位置（如果包含MOUSEEVENTF_MOVE）
- **cButtons**: 保留，设为0
- **dwExtraInfo**: 额外信息，通常为0

### 5. 窗口控制原理

#### 获取窗口句柄：
```powershell
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Window {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        
        [DllImport("user32.dll")]
        public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);
        
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@

# 获取当前活动窗口
$hWnd = [Window]::GetForegroundWindow()
$text = New-Object System.Text.StringBuilder 256
[Window]::GetWindowText($hWnd, $text, 256)
$windowTitle = $text.ToString()
```

#### 窗口操作API：
- **GetForegroundWindow**: 获取前景窗口句柄
- **GetWindowText**: 获取窗口标题
- **SetForegroundWindow**: 设置前景窗口
- **FindWindow**: 根据类名或窗口名查找窗口
- **ShowWindow**: 显示/隐藏窗口

## 🔧 防中断技术原理深度分析

### 1. 系统中断机制

#### Windows空闲检测：
1. **输入空闲计时器**: 跟踪用户输入（键盘、鼠标）活动
2. **系统空闲状态**: 一段时间无用户输入后进入空闲状态
3. **屏幕保护触发**: 空闲达到设定时间触发屏幕保护
4. **电源管理**: 进一步空闲可能触发睡眠或休眠

#### 典型超时设置：
- **屏幕保护**: 1-15分钟
- **显示器关闭**: 5-30分钟
- **系统睡眠**: 15分钟-几小时

### 2. 防中断技术原理

#### 核心思想：
模拟用户活动，重置系统空闲计时器。

#### 技术实现：
```powershell
# 防中断核心代码
function Send-AntiInterruptHeartbeat {
    param([int]$IntervalSeconds = 300)
    
    while ($true) {
        # 1. 发送回车键（最小干扰）
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        
        # 2. 轻微移动鼠标（可选）
        $pos = [System.Windows.Forms.Cursor]::Position
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($pos.X + 1, $pos.Y)
        Start-Sleep -Milliseconds 10
        [System.Windows.Forms.Cursor]::Position = $pos
        
        # 3. 记录日志
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 防中断心跳" -ForegroundColor Gray
        
        # 4. 等待间隔
        Start-Sleep -Seconds $IntervalSeconds
    }
}
```

#### 为什么回车键有效：
1. **系统输入**: 回车键被视为用户输入
2. **重置计时器**: 重置系统空闲检测计时器
3. **低干扰**: 对大多数应用无影响
4. **兼容性好**: 几乎所有Windows应用都支持

### 3. 对话框检测与处理

#### 对话框类型：
1. **系统对话框**: UAC、错误、警告、确认
2. **应用对话框**: 保存确认、退出确认、权限请求
3. **游戏对话框**: 任务提示、确认、选项

#### 检测原理：
```powershell
function Detect-InterruptDialog {
    # 获取活动窗口标题
    $activeWindow = Get-ActiveWindowTitle
    
    # 常见对话框关键词
    $dialogKeywords = @(
        "确认", "警告", "错误", "提示", 
        "是否", "确定", "取消", "继续",
        "OK", "Cancel", "Yes", "No",
        "Save", "Exit", "Permission", "Access"
    )
    
    foreach ($keyword in $dialogKeywords) {
        if ($activeWindow -match $keyword) {
            return @{
                HasDialog = $true
                WindowTitle = $activeWindow
                Keyword = $keyword
            }
        }
    }
    
    return @{ HasDialog = $false }
}
```

#### 自动处理策略：
1. **确认类对话框**: 发送回车或空格
2. **取消类对话框**: 发送ESC
3. **选项类对话框**: 根据上下文选择
4. **权限类对话框**: 可能需要用户干预

## 🎮 游戏自动化技术原理

### 1. 游戏启动自动化

#### 原理：
```powershell
# 启动游戏进程
Start-Process "D:\Netease\逆水寒\Launcher.exe" -WindowStyle Normal

# 等待游戏加载
Start-Sleep -Seconds 15

# 激活游戏窗口
$wshell = New-Object -ComObject wscript.shell
$wshell.AppActivate("逆水寒")
```

#### 关键技术：
1. **进程启动**: Start-Process启动游戏
2. **加载等待**: 给游戏足够时间初始化
3. **窗口激活**: 确保游戏窗口获得焦点
4. **错误处理**: 处理启动失败情况

### 2. 游戏内操作自动化

#### 键盘操作：
```powershell
# 游戏内常用操作
$gameActions = @{
    "移动前" = "{W}"
    "移动后" = "{S}"
    "移动左" = "{A}"
    "移动右" = "{D}"
    "跳跃" = "{SPACE}"
    "攻击" = "{F}"
    "技能1" = "1"
    "技能2" = "2"
    "确认" = "{ENTER}"
    "取消" = "{ESC}"
}

# 执行游戏操作
function Execute-GameAction {
    param([string]$Action)
    
    if ($gameActions.ContainsKey($Action)) {
        $key = $gameActions[$Action]
        [System.Windows.Forms.SendKeys]::SendWait($key)
        Write-Host "执行操作: $Action -> $key" -ForegroundColor Green
        return $true
    } else {
        Write-Host "未知操作: $Action" -ForegroundColor Red
        return $false
    }
}
```

#### 鼠标操作：
```powershell
# 游戏内鼠标操作
function Click-GamePosition {
    param([int]$X, [int]$Y)
    
    # 保存当前位置
    $originalPos = [System.Windows.Forms.Cursor]::Position
    
    # 移动到目标位置
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($X, $Y)
    Start-Sleep -Milliseconds 100
    
    # 左键点击
    [Mouse]::mouse_event($MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    Start-Sleep -Milliseconds 50
    [Mouse]::mouse_event($MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
    
    # 返回原位置（可选）
    [System.Windows.Forms.Cursor]::Position = $originalPos
}
```

### 3. 游戏截图自动化

#### 原理：
```powershell
# 使用现有screenshot技能
function Capture-GameScreenshot {
    param([string]$GameName)
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputPath = "E:\game_screenshots\$GameName-$timestamp.png"
    
    # 调用screenshot.ps1
    & "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw\skills\screenshot\screenshot.ps1" -Output $outputPath
    
    if (Test-Path $outputPath) {
        Write-Host "✅ 截图保存: $outputPath" -ForegroundColor Green
        return $outputPath
    } else {
        Write-Host "❌ 截图失败" -ForegroundColor Red
        return $null
    }
}
```

## 🔄 多开游戏管理原理

### 1. 进程管理
```powershell
# 启动多个游戏实例
$games = @(
    @{Name="逆水寒"; Path="D:\Netease\逆水寒\Launcher.exe"},
    @{Name="梦幻西游"; Path="D:\Program Files (x86)\梦幻西游\mhmain.exe"},
    @{Name="剑侠世界.起源"; Path="D:\SeasunJSQYos\SeasunGame.exe"}
)

foreach ($game in $games) {
    Write-Host "启动游戏: $($game.Name)" -ForegroundColor Cyan
    $process = Start-Process $game.Path -PassThru -WindowStyle Normal
    Start-Sleep -Seconds 5
    
    if ($process.HasExited) {
        Write-Host "❌ 游戏启动失败: $($game.Name)" -ForegroundColor Red
    } else {
        Write-Host "✅ 游戏启动成功: $($game.Name) (PID: $($process.Id))" -ForegroundColor Green
    }
}
```

### 2. 窗口切换管理
```powershell
# 轮询操作多个游戏窗口
function Rotate-GameWindows {
    param([string[]]$GameWindows, [int]$TimePerWindow = 60)
    
    while ($true) {
        foreach ($window in $GameWindows) {
            Write-Host "切换到: $window" -ForegroundColor Yellow
            
            # 激活窗口
            $wshell = New-Object -ComObject wscript.shell
            $activated = $wshell.AppActivate($window)
            
            if ($activated) {
                Write-Host "✅ 窗口激活成功" -ForegroundColor Green
                
                # 执行游戏内操作
                Execute-GameAction -Action "确认"
                Start-Sleep -Seconds 2
                Execute-GameAction -Action "攻击"
                
                # 截图
                Capture-GameScreenshot -GameName $window
            } else {
                Write-Host "❌ 窗口激活失败" -ForegroundColor Red
            }
            
            # 等待一段时间
            Start-Sleep -Seconds $TimePerWindow
        }
    }
}
```

## 🛡️ 稳定性与错误处理

### 1. 错误处理机制
```powershell
function Safe-SendKeys {
    param([string]$Keys)
    
    try {
        [System.Windows.Forms.SendKeys]::SendWait($Keys)
        Write-Log "INFO" "成功发送按键: $Keys"
        return $true
    } catch {
        Write-Log "ERROR" "发送按键失败: $Keys - $_"
        return $false
    }
}

function Safe-MouseClick {
    param([int]$X, [int]$Y)
    
    try {
        Click-GamePosition -X $X -Y $Y
        Write-Log "INFO" "成功点击位置: ($X, $Y)"
        return $true
    } catch {
        Write-Log "ERROR" "鼠标点击失败: ($X, $Y) - $_"
        return $false
    }
}
```

### 2. 恢复机制
```powershell
function Recover-FromFailure {
    param([string]$FailureType)
    
    switch ($FailureType) {
        "GameCrashed" {
            Write-Log "WARN" "游戏崩溃，尝试重新启动"
            # 结束残留进程
            Get-Process -Name "game_process" -ErrorAction SilentlyContinue | Stop-Process -Force
            # 重新启动
            Start-GameAutomation
        }
        "WindowLost" {
            Write-Log "WARN" "窗口丢失，尝试重新激活"
            # 重新查找窗口
            $wshell = New-Object -ComObject wscript.shell
            $wshell.AppActivate("游戏窗口标题")
        }
        "SystemInterrupt" {
            Write-Log "WARN" "系统中断，发送恢复信号"
            # 发送多次回车恢复
            1..3 | ForEach-Object {
                [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep -Milliseconds 500
            }
        }
        default {
            Write-Log "ERROR" "未知失败类型: $FailureType"
        }
    }
}
```

## 📊 性能优化原理

### 1. 资源管理
```powershell
# 监控资源使用
function Monitor-Resources {
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $memory = (Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples.CookedValue
    $processCount = (Get-Process).Count
    
    Write-Log "DEBUG" "系统资源 - CPU: $([math]::Round($cpu, 1))%, 内存: $([math]::Round($memory, 1))%, 进程: $processCount"
    
    # 资源过高时调整
    if ($cpu -gt 80 -or $memory -gt 85) {
        Write-Log "WARN" "资源使用过高，调整操作频率"
        return $false
    }
    
    return $true
}
```

### 2. 操作频率优化
```powershell
# 动态调整操作频率
$baseInterval = 300  # 5分钟
$currentInterval = $baseInterval

function Adjust-HeartbeatInterval {
    param([float]$CpuUsage, [float]$MemoryUsage)
    
    if ($CpuUsage -gt 70 -or $MemoryUsage -gt 80) {
        # 资源紧张，延长间隔
        $newInterval = [math]::Min($currentInterval * 1.5, 600)  # 最多10分钟
        Write-Log "INFO" "资源紧张，延长心跳间隔: $currentInterval → $newInterval 秒"
        $currentInterval = $newInterval
    } elseif ($CpuUsage -lt 30 -and $MemoryUsage -lt