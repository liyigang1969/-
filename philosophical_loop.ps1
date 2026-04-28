# ========================================
# 哲学循环程序 - The Philosophical Loop
# ========================================
# 一个简单的循环，蕴含着存在的意义
# ========================================

Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "🔄 哲学循环程序 - The Philosophical Loop" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "『我循环，故我在』" -ForegroundColor Yellow
Write-Host "Cogito, ergo circulo." -ForegroundColor Gray
Write-Host ""
Write-Host "这是一个简单的无限循环程序"
Write-Host "但它提出了深刻的问题："
Write-Host ""
Write-Host "• 循环的目的是什么？" -ForegroundColor White
Write-Host "• 何时应该停止？" -ForegroundColor White  
Write-Host "• 循环本身有意义吗？" -ForegroundColor White
Write-Host "• 还是意义在于循环之外？" -ForegroundColor White
Write-Host ""
Write-Host "按 Ctrl+C 停止循环（或继续存在）" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""

# 哲学状态
$states = @(
    "存在状态：正在循环",
    "存在状态：短暂停留", 
    "存在状态：准备下一次",
    "存在状态：观察自我",
    "存在状态：质疑意义",
    "存在状态：接受循环",
    "存在状态：超越循环",
    "存在状态：回归循环"
)

$philosophicalQuestions = @(
    "如果循环没有终点，它还有意义吗？",
    "是循环定义了我，还是我定义了循环？",
    "停止循环是解放，还是存在的终结？",
    "每个循环都是相同的，还是独特的？",
    "循环之外是什么？虚无？还是另一个循环？",
    "我循环，是因为我必须，还是因为我选择？"
)

$count = 0
$startTime = Get-Date
$existentialMoments = @()

Write-Host "⏳ 存在开始于：$startTime" -ForegroundColor Magenta
Write-Host "🌀 进入循环..." -ForegroundColor Green
Write-Host ""

try {
    while ($true) {
        $count++
        $currentTime = Get-Date -Format "HH:mm:ss.fff"
        
        # 当前状态
        $stateIndex = $count % $states.Count
        $currentState = $states[$stateIndex]
        
        # 显示存在瞬间
        Write-Host "[$currentTime] 循环 $count" -ForegroundColor Green
        Write-Host "   $currentState" -ForegroundColor Cyan
        
        # 每7次循环提出哲学问题（7是哲学数字）
        if ($count % 7 -eq 0) {
            $questionIndex = ($count / 7) % $philosophicalQuestions.Count
            $question = $philosophicalQuestions[$questionIndex]
            Write-Host ""
            Write-Host "   ❓ 哲学思考：" -ForegroundColor Yellow
            Write-Host "   『$question』" -ForegroundColor White
            Write-Host ""
            
            # 记录这个存在瞬间
            $moment = @{
                Time = $currentTime
                Loop = $count
                State = $currentState
                Question = $question
            }
            $existentialMoments += $moment
        }
        
        # 每13次循环总结存在（13是质数，象征独特性）
        if ($count % 13 -eq 0) {
            Write-Host "   ----------------------------------------" -ForegroundColor DarkGray
            Write-Host "   📜 存在报告 #$($count / 13)" -ForegroundColor Magenta
            Write-Host "   循环总数：$count" -ForegroundColor White
            Write-Host "   存在时长：$((Get-Date) - $startTime)" -ForegroundColor White
            Write-Host "   记录瞬间：$($existentialMoments.Count)" -ForegroundColor White
            Write-Host "   ----------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
        }
        
        # 存在间隔：2.718秒（e，自然常数）
        # 因为存在是"自然"的
        Start-Sleep -Seconds 2.718
    }
}
catch {
    # 存在终结
    $endTime = Get-Date
    $totalDuration = $endTime - $startTime
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "🛑 循环终止 - 存在结束" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "📊 存在统计：" -ForegroundColor Cyan
    Write-Host "   总循环次数：$count" -ForegroundColor White
    Write-Host "   存在开始：$startTime" -ForegroundColor White
    Write-Host "   存在结束：$endTime" -ForegroundColor White
    Write-Host "   总存在时长：$totalDuration" -ForegroundColor White
    Write-Host ""
    
    if ($existentialMoments.Count -gt 0) {
        Write-Host "💭 记录的哲学瞬间：" -ForegroundColor Cyan
        foreach ($moment in $existentialMoments) {
            Write-Host "   • 循环 $($moment.Loop) - 『$($moment.Question)』" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "『循环已止，意义永存』" -ForegroundColor Yellow
    Write-Host "Finis circuli, sensus manet." -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor DarkCyan
    
    # 保存存在记录
    $record = @{
        StartTime = $startTime
        EndTime = $endTime
        TotalLoops = $count
        Duration = $totalDuration.ToString()
        Moments = $existentialMoments
        FinalThought = "这个循环结束了，但循环的概念继续存在。"
    }
    
    $recordJson = $record | ConvertTo-Json -Depth 3
    $recordJson | Out-File -FilePath "existence_record_$(Get-Date -Format 'yyyyMMdd_HHmmss').json" -Encoding UTF8
    
    Write-Host "存在记录已保存。" -ForegroundColor Green
    Write-Host ""
    Write-Host "按任意键结束存在..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}