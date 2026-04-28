# Encoding fix script - English only
Write-Host "=== Start fixing file encoding ===" -ForegroundColor Cyan

$files = @(
    "work_queue.json",
    "work_state.json", 
    "HEARTBEAT.md"
)

foreach ($file in $files) {
    $fullPath = "E:\openclaw-data\.openclaw\workspace\$file"
    
    if (Test-Path $fullPath) {
        Write-Host "Processing: $file" -ForegroundColor Green
        
        try {
            # Read original content
            $content = Get-Content $fullPath -Raw -ErrorAction Stop
            
            # Save as UTF-8 without BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($fullPath, $content, $utf8NoBom)
            
            Write-Host "  Saved as UTF-8 (no BOM)" -ForegroundColor Green
            
            # Verify JSON files
            if ($file -like "*.json") {
                try {
                    $jsonContent = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
                    $test = $jsonContent | ConvertFrom-Json -ErrorAction Stop
                    Write-Host "  JSON format is valid" -ForegroundColor Green
                }
                catch {
                    Write-Host "  JSON format invalid: $_" -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "  Failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Encoding fix complete ===" -ForegroundColor Cyan
Write-Host "Now you can retest automation workflow" -ForegroundColor Green