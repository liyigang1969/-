# Simple Loop Program
# Just runs in a loop

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Simple Loop Program v1.0" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This program runs in an infinite loop"
Write-Host "Press Ctrl+C to stop"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$count = 0
$startTime = Get-Date

Write-Host "Start time: $startTime"
Write-Host "Program started..."
Write-Host ""

try {
    while ($true) {
        $count++
        $currentTime = Get-Date -Format "HH:mm:ss"
        
        Write-Host "[$currentTime] Loop $count" -ForegroundColor Green
        
        # Show status every 10 loops
        if ($count % 10 -eq 0) {
            Write-Host "----------------------------------------" -ForegroundColor Gray
            Write-Host "Status Report" -ForegroundColor Yellow
            Write-Host "  Loops: $count" -ForegroundColor White
            Write-Host "  Start: $startTime" -ForegroundColor White
            Write-Host "  Current: $(Get-Date)" -ForegroundColor White
            Write-Host "----------------------------------------" -ForegroundColor Gray
            Write-Host ""
        }
        
        # Wait 3 seconds
        Start-Sleep -Seconds 3
    }
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Program Stopped" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Total loops: $count" -ForegroundColor White
    Write-Host "Start time: $startTime" -ForegroundColor White
    Write-Host "End time: $(Get-Date)" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}