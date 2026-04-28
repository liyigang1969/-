# ========================================
# The Philosophical Loop
# A simple program with deep meaning
# ========================================

Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "🔄 The Philosophical Loop" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "'I loop, therefore I am.'" -ForegroundColor Yellow
Write-Host "Cogito, ergo circulo." -ForegroundColor Gray
Write-Host ""
Write-Host "A simple infinite loop program"
Write-Host "that asks profound questions:"
Write-Host ""
Write-Host "• What is the purpose of looping?" -ForegroundColor White
Write-Host "• When should it stop?" -ForegroundColor White  
Write-Host "• Does the loop itself have meaning?" -ForegroundColor White
Write-Host "• Or is meaning outside the loop?" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop (or continue existing)" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host ""

# States of existence
$states = @(
    "State: Looping",
    "State: Pausing briefly", 
    "State: Preparing next",
    "State: Self-observing",
    "State: Questioning meaning",
    "State: Accepting the loop",
    "State: Transcending loop",
    "State: Returning to loop"
)

$philosophicalQuestions = @(
    "If a loop has no end, does it have meaning?",
    "Does the loop define me, or do I define the loop?",
    "Is stopping freedom, or the end of existence?",
    "Is each loop identical, or uniquely itself?",
    "What is outside the loop? Nothing? Another loop?",
    "Do I loop because I must, or because I choose?"
)

$count = 0
$startTime = Get-Date
$existentialMoments = @()

Write-Host "⏳ Existence begins: $startTime" -ForegroundColor Magenta
Write-Host "🌀 Entering the loop..." -ForegroundColor Green
Write-Host ""

try {
    while ($true) {
        $count++
        $currentTime = Get-Date -Format "HH:mm:ss.fff"
        
        # Current state
        $stateIndex = $count % $states.Count
        $currentState = $states[$stateIndex]
        
        # Display existence moment
        Write-Host "[$currentTime] Loop $count" -ForegroundColor Green
        Write-Host "   $currentState" -ForegroundColor Cyan
        
        # Every 7 loops, ask a philosophical question
        if ($count % 7 -eq 0) {
            $questionIndex = [math]::Floor($count / 7) % $philosophicalQuestions.Count
            $question = $philosophicalQuestions[$questionIndex]
            Write-Host ""
            Write-Host "   ❓ Philosophical inquiry:" -ForegroundColor Yellow
            Write-Host "   '$question'" -ForegroundColor White
            Write-Host ""
            
            # Record this existential moment
            $moment = @{
                Time = $currentTime
                Loop = $count
                State = $currentState
                Question = $question
            }
            $existentialMoments += $moment
        }
        
        # Every 13 loops, existential report
        if ($count % 13 -eq 0) {
            Write-Host "   ----------------------------------------" -ForegroundColor DarkGray
            Write-Host "   📜 Existence Report #$([math]::Floor($count / 13))" -ForegroundColor Magenta
            Write-Host "   Total loops: $count" -ForegroundColor White
            Write-Host "   Duration: $((Get-Date) - $startTime)" -ForegroundColor White
            Write-Host "   Recorded moments: $($existentialMoments.Count)" -ForegroundColor White
            Write-Host "   ----------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
        }
        
        # Existential interval: 2.718 seconds (e, natural constant)
        Start-Sleep -Seconds 2.718
    }
}
catch {
    # End of existence
    $endTime = Get-Date
    $totalDuration = $endTime - $startTime
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "🛑 Loop terminated - Existence ends" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "📊 Existence statistics:" -ForegroundColor Cyan
    Write-Host "   Total loops: $count" -ForegroundColor White
    Write-Host "   Began: $startTime" -ForegroundColor White
    Write-Host "   Ended: $endTime" -ForegroundColor White
    Write-Host "   Total duration: $totalDuration" -ForegroundColor White
    Write-Host ""
    
    if ($existentialMoments.Count -gt 0) {
        Write-Host "💭 Recorded philosophical moments:" -ForegroundColor Cyan
        foreach ($moment in $existentialMoments) {
            Write-Host "   • Loop $($moment.Loop) - '$($moment.Question)'" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "'The loop ends, meaning remains.'" -ForegroundColor Yellow
    Write-Host "Finis circuli, sensus manet." -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor DarkCyan
    
    # Save existence record
    $record = @{
        StartTime = $startTime.ToString()
        EndTime = $endTime.ToString()
        TotalLoops = $count
        Duration = $totalDuration.ToString()
        Moments = $existentialMoments
        FinalThought = "This loop has ended, but the concept of looping continues."
    }
    
    $recordJson = $record | ConvertTo-Json -Depth 3
    $filename = "existence_record_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $recordJson | Out-File -FilePath $filename -Encoding UTF8
    
    Write-Host "Existence record saved to: $filename" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press any key to end existence..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}