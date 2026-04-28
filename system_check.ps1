Write-Host "=== Windows系统信息 ===" -ForegroundColor Green
Write-Host "操作系统: $([System.Environment]::OSVersion.VersionString)"
Write-Host "64位系统: $([System.Environment]::Is64BitOperatingSystem)"
Write-Host "当前用户: $([System.Environment]::UserName)"
Write-Host "计算机名: $([System.Environment]::MachineName)"

Write-Host "`n=== 磁盘信息 ===" -ForegroundColor Green
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | Format-Table Name, @{Name="总空间(GB)";Expression={[math]::Round($_.Free + $_.Used, 2)}}, @{Name="已用空间(GB)";Expression={[math]::Round($_.Used, 2)}}, @{Name="可用空间(GB)";Expression={[math]::Round($_.Free, 2)}}, @{Name="使用率(%)";Expression={[math]::Round(($_.Used/($_.Free + $_.Used))*100, 2)}}

Write-Host "`n=== Node.js检查 ===" -ForegroundColor Green
$nodePath = Get-Command node -ErrorAction SilentlyContinue
if ($nodePath) {
    Write-Host "Node.js已安装: $($nodePath.Source)"
    Write-Host "Node版本: $(node --version)"
} else {
    Write-Host "Node.js未安装或不在PATH中" -ForegroundColor Yellow
}

Write-Host "`n=== OpenClaw文件检查 ===" -ForegroundColor Green
$openclawPath = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
if (Test-Path $openclawPath) {
    Write-Host "OpenClaw安装目录存在: $openclawPath"
    $packageJson = Get-Content "$openclawPath\package.json" | ConvertFrom-Json
    Write-Host "OpenClaw版本: $($packageJson.version)"
    Write-Host "Node版本要求: $($packageJson.engines.node)"
} else {
    Write-Host "OpenClaw安装目录不存在" -ForegroundColor Red
}

Write-Host "`n=== OpenClaw数据目录检查 ===" -ForegroundColor Green
$dataPath = "E:\openclaw-data\.openclaw"
if (Test-Path $dataPath) {
    Write-Host "OpenClaw数据目录存在: $dataPath"
    $files = Get-ChildItem $dataPath -Recurse -File | Measure-Object
    Write-Host "文件数量: $($files.Count)"
} else {
    Write-Host "OpenClaw数据目录不存在" -ForegroundColor Yellow
}

Write-Host "`n=== 系统完整性检查 ===" -ForegroundColor Green
Write-Host "运行DISM检查系统映像..."
try {
    dism /Online /Cleanup-Image /CheckHealth
} catch {
    Write-Host "DISM检查失败: $_" -ForegroundColor Yellow
}

Write-Host "`n运行系统文件检查器..."
try {
    sfc /verifyonly
} catch {
    Write-Host "SFC检查失败: $_" -ForegroundColor Yellow
}