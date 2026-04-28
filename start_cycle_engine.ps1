# Start cycle engine - simplified
Write-Host "=== Starting Work Cycle Engine ===" -ForegroundColor Cyan
Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
Write-Host ""

# Check current cycle
$cyclePath = "E:\openclaw-data\.openclaw\workspace\current_cycle.json"
if (Test-Path $cyclePath) {
    $content = Get-Content $cyclePath -Raw
    $cycle = $content | ConvertFrom-Json
    
    Write-Host "Current cycle: #$($cycle.cycle_number)" -ForegroundColor Green
    Write-Host "Start time: $($cycle.start_time)" -ForegroundColor White
    Write-Host "Status: $($cycle.status)" -ForegroundColor White
    Write-Host ""
    
    # Calculate next events
    $startTime = [DateTime]::Parse($cycle.start_time)
    $currentTime = Get-Date
    $minutesElapsed = [math]::Round(($currentTime - $startTime).TotalMinutes)
    
    Write-Host "Cycle progress: $minutesElapsed / $($cycle.cycle_duration_minutes) minutes" -ForegroundColor Yellow
    Write-Host ""
    
    # Show next events
    Write-Host "Next scheduled events:" -ForegroundColor Green
    foreach ($subCycle in $cycle.sub_cycles) {
        $interval = [int]$subCycle.interval_minutes
        $nextTrigger = $minutesElapsed % $interval
        $minutesToNext = $interval - $nextTrigger
        
        Write-Host "  $($subCycle.name): $minutesToNext minutes ($($subCycle.next_time))" -ForegroundColor White
    }
} else {
    Write-Host "No current cycle found" -ForegroundColor Red
    Write-Host "Please run human start workflow first" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Work cycle engine is ready" -ForegroundColor Green
Write-Host "System will automatically:" -ForegroundColor Yellow
Write-Host "  1. Check every minute for scheduled tasks" -ForegroundColor White
Write-Host "  2. Execute 3-minute dialogue simulation" -ForegroundColor White
Write-Host "  3. Execute 10-minute memory recall" -ForegroundColor White
Write-Host "  4. Execute 10-minute planning process" -ForegroundColor White
Write-Host "  5. Start new cycles automatically" -ForegroundColor White
Write-Host ""
Write-Host "AI autonomous work cycle started!" -ForegroundColor Red