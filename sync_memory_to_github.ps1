# OpenClaw Memory Sync to GitHub
# Usage: powershell -ExecutionPolicy Bypass -File sync_memory_to_github.ps1

param(
    [string]$RepoUrl = "https://github.com/liyigang1969/openclaw-memory.git",
    [string]$Branch = "main"
)

$Root = "F:\openclaw-data\.openclaw\workspace"
$RepoDir = Join-Path $Root ".memory_repo"
$MemoryDir = Join-Path $Root "memory"
$LogFile = Join-Path $Root "sync_log.txt"
$PendingFile = Join-Path $Root ".sync_pending.json"

function Log {
    param([string]$Msg)
    $t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$t $Msg" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Test network
Write-Host "[CHECK] Testing GitHub connectivity..."
try {
    $req = [System.Net.WebRequest]::Create("https://github.com")
    $req.Timeout = 8000
    $res = $req.GetResponse()
    $res.Close()
} catch {
    Write-Host "[WARN] GitHub unreachable - changes will be queued"
    $pending = @{
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        reason = "network_unreachable"
    }
    $pending | ConvertTo-Json | Out-File $PendingFile -Encoding UTF8
    Log "PENDING: GitHub unreachable"
    return
}

Write-Host "[OK] GitHub reachable"

# Go to repo dir
if (-not (Test-Path $RepoDir)) {
    New-Item -ItemType Directory -Path $RepoDir -Force | Out-Null
}

Set-Location $RepoDir

# Init or pull
if (-not (Test-Path (Join-Path $RepoDir ".git"))) {
    Write-Host "[INIT] Creating new repo..."
    git init
    git config user.name "liyigang1969"
    git config user.email "liyigang1969@163.com"
    git remote add origin $RepoUrl
} else {
    Write-Host "[SYNC] Repo exists, updating..."
}

# Copy memory files
if (Test-Path $MemoryDir) {
    $target = Join-Path $RepoDir "memory"
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Copy-Item -Path "$MemoryDir\*" -Destination $target -Recurse -Force
}

# Commit and push
$changes = git status --porcelain
if ($changes) {
    Write-Host "[COMMIT] Changes detected, committing..."
    git add -A
    $msg = "Auto sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $msg
    Write-Host "[PUSH] Pushing to GitHub..."
    $result = git push -u origin $Branch 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Sync successful!"
        Log "OK: $msg"
    } else {
        Write-Host "[ERROR] Push failed"
        Log "FAIL: push error"
        $result | Out-File $PendingFile -Encoding UTF8
    }
} else {
    Write-Host "[OK] No changes to sync"
    Log "NO_CHANGES"
}

# Cleanup pending
if (Test-Path $PendingFile) {
    Remove-Item $PendingFile -Force
}

Set-Location $Root