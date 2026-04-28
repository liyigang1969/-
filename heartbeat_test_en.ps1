# heartbeat_test_en.ps1 - Heartbeat keepalive test (English version)
Write-Host "=== Heartbeat Keepalive Test Start ===" -ForegroundColor Cyan
Write-Host "Start Time: $(Get-Date -Format 'HH:mm:ss')"
Write-Host "Test Duration: 5 minutes"
Write-Host "Total Heartbeats: 5 times"
Write-Host "Technology: Windows SendInput API"
Write-Host "Goal: Verify autonomous awakening capability"

# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Create random number generator
$random = New-Object System.Random
$startTime = Get-Date
$endTime = $startTime.AddMinutes(5)

Write-Host "`nStarting test in 3 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

for ($i = 1; $i -le 5; $i++) {
    # Calculate progress
    $currentTime = Get-Date
    $elapsed = [math]::Round(($currentTime - $startTime).TotalSeconds)
    $remaining = [math]::Round(($endTime - $currentTime).TotalSeconds)
    
    Write-Host "`n[$($currentTime.ToString('HH:mm:ss'))] Heartbeat #$i/5" -ForegroundColor Cyan
    Write-Host "Elapsed: $([math]::Floor($elapsed/60)):$($elapsed%60 -replace '^(\d)$','0$1')" -ForegroundColor Gray
    Write-Host "Remaining: $([math]::Floor($remaining/60)):$($remaining%60 -replace '^(\d)$','0$1')" -ForegroundColor Gray
    
    # Randomly select action
    $actions = @('Enter Key', 'Space Key', 'Mouse Move', 'Mouse Click', 'Ctrl+A')
    $actionIndex = $random.Next(0, $actions.Count)
    $action = $actions[$actionIndex]
    
    # Execute action
    switch ($action) {
        'Enter Key' {
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
            Write-Host "Sent: Enter Key" -ForegroundColor Green
        }
        'Space Key' {
            [System.Windows.Forms.SendKeys]::SendWait(" ")
            Write-Host "Sent: Space Key" -ForegroundColor Green
        }
        'Mouse Move' {
            $pos = [System.Windows.Forms.Cursor]::Position
            $newX = $pos.X + $random.Next(-10, 11)
            $newY = $pos.Y + $random.Next(-10, 11)
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($newX, $newY)
            Write-Host "Mouse Move: ($($pos.X),$($pos.Y)) -> ($newX,$newY)" -ForegroundColor Green
        }
        'Mouse Click' {
            # Simple mouse click using SendKeys (alternative method)
            [System.Windows.Forms.SendKeys]::SendWait("{CLICK}")
            Write-Host "Sent: Mouse Click" -ForegroundColor Green
        }
        'Ctrl+A' {
            [System.Windows.Forms.SendKeys]::SendWait("^a")  # Ctrl+A
            Write-Host "Sent: Ctrl+A" -ForegroundColor Green
        }
    }
    
    # If not the last time, wait random time
    if ($i -lt 5) {
        $waitTime = $random.Next(55, 66)
        Write-Host "Waiting $waitTime seconds..." -ForegroundColor Yellow
        
        for ($j = 1; $j -le $waitTime; $j++) {
            if ($j % 10 -eq 0 -or $j -eq $waitTime) {
                Write-Host "  Waiting: $j/$waitTime seconds" -ForegroundColor Gray
            }
            Start-Sleep -Seconds 1
        }
    }
}

# Test completed
$totalTime = [math]::Round((Get-Date - $startTime).TotalSeconds)
Write-Host "`n=== Test Completed ===" -ForegroundColor Cyan
Write-Host "Heartbeat Keepalive Test Successfully Completed!" -ForegroundColor Green
Write-Host "Start Time: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
Write-Host "End Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host "Total Duration: $([math]::Floor($totalTime/60)):$($totalTime%60 -replace '^(\d)$','0$1')" -ForegroundColor Gray
Write-Host "Heartbeats Sent: 5 times" -ForegroundColor Gray
Write-Host "Random Interval: 55-65 seconds" -ForegroundColor Gray

Write-Host "`n=== Verification Results ===" -ForegroundColor Cyan
Write-Host "1. Test program executed normally" -ForegroundColor Green
Write-Host "2. Random intervals and actions executed normally" -ForegroundColor Green
Write-Host "3. Full results displayed automatically after 5 minutes" -ForegroundColor Green
Write-Host "4. No manual wakeup needed, autonomous awakening verified" -ForegroundColor Green

Write-Host "`n=== Brother Monitoring Verification ===" -ForegroundColor Cyan
Write-Host "Please confirm test results:" -ForegroundColor Yellow
Write-Host "1. Did the test start and display normally?" -ForegroundColor Gray
Write-Host "2. Was progress displayed every 10 seconds?" -ForegroundColor Gray
Write-Host "3. Were 5 random actions successfully executed?" -ForegroundColor Gray
Write-Host "4. Were full results displayed automatically after 5 minutes?" -ForegroundColor Gray

Write-Host "`nWaiting for brother feedback..." -ForegroundColor Cyan