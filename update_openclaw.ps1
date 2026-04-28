# OpenClaw更新脚本
Write-Host "正在检查OpenClaw最新版本..."

try {
    # 获取最新版本信息
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/openclaw/openclaw/releases/latest" -ErrorAction Stop
    $latestVersion = $latestRelease.tag_name
    $latestVersion = $latestVersion -replace '^v', ''
    
    Write-Host "最新版本: $latestVersion"
} catch {
    Write-Host "无法获取最新版本信息: $_"
    $latestVersion = "2026.4.14" # 已知的最新版本
    Write-Host "使用已知最新版本: $latestVersion"
}

# 检查当前版本
$currentDir = "C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw"
if (Test-Path "$currentDir\package.json") {
    $packageJson = Get-Content "$currentDir\package.json" | ConvertFrom-Json
    $currentVersion = $packageJson.version
    Write-Host "当前版本: $currentVersion"
} else {
    Write-Host "无法找到当前安装"
    exit 1
}

if ($latestVersion -eq $currentVersion) {
    Write-Host "已经是最新版本，无需更新。"
    exit 0
}

Write-Host "发现新版本，开始更新建议..."
Write-Host ""
Write-Host "由于这是一个临时USB安装，建议:"
Write-Host "1. 重新下载最新版本的OpenClaw"
Write-Host "2. 使用以下命令尝试更新:"
Write-Host "   cd '$currentDir'"
Write-Host "   node openclaw.mjs update --yes"
Write-Host ""
Write-Host "下载链接: https://github.com/openclaw/openclaw/releases/latest"