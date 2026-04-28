# 下载Node.js安装程序
$url = "https://nodejs.org/dist/latest-v22.x/node-v22.22.2-x64.msi"
$output = "C:\Users\lenovo\Downloads\node-v22.22.2-x64.msi"

Write-Host "正在下载Node.js v22.22.2..." -ForegroundColor Green

# 创建下载目录
$downloadDir = Split-Path $output -Parent
if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force
}

# 下载文件
try {
    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Host "下载完成: $output" -ForegroundColor Green
    Write-Host "文件大小: $([math]::Round((Get-Item $output).Length / 1MB, 2)) MB" -ForegroundColor Green
    
    # 验证文件
    if (Test-Path $output) {
        Write-Host "文件验证成功，准备安装..." -ForegroundColor Green
        return $output
    } else {
        Write-Host "文件下载失败" -ForegroundColor Red
        return $null
    }
} catch {
    Write-Host "下载失败: $_" -ForegroundColor Red
    return $null
}