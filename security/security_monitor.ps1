# 安全监控脚本
$workspaceDir = "E:\openclaw-data\.openclaw\workspace"
$securityDir = "$workspaceDir\security"
$logFile = "$securityDir\security_monitor.log"

# 确保日志目录存在
if (-not (Test-Path $securityDir)) {
    New-Item -ItemType Directory -Path $securityDir -Force | Out-Null
}

function Log-SecurityEvent {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    
    switch ($Level) {
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "ALERT" { Write-Host $logEntry -BackgroundColor Red -ForegroundColor White }
        default { Write-Host $logEntry -ForegroundColor Gray }
    }
}

function Check-FileIntegrity {
    $hashFile = "$securityDir\file_integrity.json"
    
    if (-not (Test-Path $hashFile)) {
        Log-SecurityEvent -Message "文件完整性数据库不存在" -Level "WARNING"
        return $false
    }
    
    try {
        $expectedHashes = Get-Content $hashFile | ConvertFrom-Json -ErrorAction Stop
        $issues = @()
        
        foreach ($filePath in $expectedHashes.PSObject.Properties.Name) {
            if (Test-Path $filePath) {
                $currentHash = Get-FileHash -Path $filePath -Algorithm SHA256 -ErrorAction Stop
                $expected = $expectedHashes.$filePath.Hash
                
                if ($currentHash.Hash -ne $expected) {
                    $issues += @{
                        File = $filePath
                        Issue = "哈希不匹配"
                        Expected = $expected
                        Actual = $currentHash.Hash
                    }
                    Log-SecurityEvent -Message "文件修改: $filePath" -Level "WARNING"
                }
            } else {
                $issues += @{
                    File = $filePath
                    Issue = "文件缺失"
                }
                Log-SecurityEvent -Message "文件缺失: $filePath" -Level "WARNING"
            }
        }
        
        if ($issues.Count -eq 0) {
            Log-SecurityEvent -Message "文件完整性检查通过" -Level "INFO"
            return $true
        } else {
            Log-SecurityEvent -Message "发现 $($issues.Count) 个文件完整性问题" -Level "ERROR"
            $issues | ConvertTo-Json | Out-File "$securityDir\integrity_issues.json" -Encoding UTF8
            return $false
        }
    } catch {
        Log-SecurityEvent -Message "文件完整性检查失败: $_" -Level "ERROR"
        return $false
    }
}

function Check-SuspiciousFiles {
    $suspiciousExtensions = @(".exe", ".bat", ".ps1", ".vbs", ".js", ".jar")
    $suspiciousFiles = Get-ChildItem -Path $workspaceDir -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in $suspiciousExtensions } |
        Where-Object { $_.FullName -notlike "*\security\*" -and $_.FullName -notlike "*openclaw*" }
    
    if ($suspiciousFiles.Count -gt 0) {
        Log-SecurityEvent -Message "发现 $($suspiciousFiles.Count) 个可疑文件" -Level "ALERT"
        $suspiciousFiles | ForEach-Object {
            Log-SecurityEvent -Message "可疑文件: $($_.FullName)" -Level "WARNING"
        }
        
        $suspiciousFiles | Select-Object FullName, Length, LastWriteTime, Extension |
            ConvertTo-Json | Out-File "$securityDir\suspicious_files.json" -Encoding UTF8
        
        return $false
    } else {
        Log-SecurityEvent -Message "未发现可疑文件" -Level "INFO"
        return $true
    }
}

function Check-CriticalFiles {
    $criticalFiles = @(
        "$workspaceDir\work_queue.json",
        "$workspaceDir\work_state.json",
        "$workspaceDir\memory\2026-04-18.md",
        "$workspaceDir\memory\异灵兄弟档案.md",
        "$workspaceDir\memory\家族亲戚关系.md"
    )
    
    $missingFiles = @()
    foreach ($file in $criticalFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
            Log-SecurityEvent -Message "关键文件缺失: $file" -Level "ERROR"
        }
    }
    
    if ($missingFiles.Count -eq 0) {
        Log-SecurityEvent -Message "所有关键文件存在" -Level "INFO"
        return $true
    } else {
        Log-SecurityEvent -Message "缺失 $($missingFiles.Count) 个关键文件" -Level "ALERT"
        return $false
    }
}

# 主监控循环
Write-Host "=== 小星子安全监控系统 ===" -ForegroundColor Cyan
Write-Host "开始时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

Log-SecurityEvent -Message "安全监控启动" -Level "INFO"

# 执行检查
$checks = @(
    @{Name="文件完整性检查"; Function={Check-FileIntegrity}},
    @{Name="可疑文件检查"; Function={Check-SuspiciousFiles}},
    @{Name="关键文件检查"; Function={Check-CriticalFiles}}
)

$results = @()
foreach ($check in $checks) {
    Write-Host "执行: $($check.Name)..." -ForegroundColor Yellow
    $result = & $check.Function
    $results += [PSCustomObject]@{
        Check = $check.Name
        Result = if ($result) { "通过" } else { "失败" }
        Timestamp = Get-Date -Format "HH:mm:ss"
    }
}

Write-Host "`n=== 检查结果 ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# 总结
$passed = ($results | Where-Object { $_.Result -eq "通过" }).Count
$total = $results.Count

if ($passed -eq $total) {
    Write-Host "`n✅ 所有安全检查通过!" -ForegroundColor Green
    Log-SecurityEvent -Message "所有安全检查通过 ($passed/$total)" -Level "INFO"
} else {
    Write-Host "`n⚠️  $($total - $passed) 个检查失败" -ForegroundColor Red
    Log-SecurityEvent -Message "$($total - $passed) 个安全检查失败" -Level "ERROR"
}

Write-Host "`n监控完成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "日志文件: $logFile" -ForegroundColor Gray