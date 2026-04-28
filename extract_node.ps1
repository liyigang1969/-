# Node.js 解压安装脚本

Write-Host "=== Node.js ZIP 解压安装 ===" -ForegroundColor Cyan

# 检查ZIP文件
$zipPath = "C:\Users\lenovo\Downloads\node-v22.22.2-win-x64.zip"
if (-not (Test-Path $zipPath)) {
    Write-Host "错误: ZIP文件不存在" -ForegroundColor Red
    Write-Host "请先下载: https://nodejs.org/dist/latest-v22.x/node-v22.22.2-win-x64.zip" -ForegroundColor Yellow
    exit 1
}

Write-Host "找到ZIP文件: $zipPath" -ForegroundColor Green
$fileSize = (Get-Item $zipPath).Length / 1MB
Write-Host "文件大小: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green

# 解压目录
$extractDir = "C:\nodejs"
Write-Host "`n解压到: $extractDir" -ForegroundColor Yellow

# 如果目录已存在，询问是否覆盖
if (Test-Path $extractDir) {
    Write-Host "警告: 目录已存在: $extractDir" -ForegroundColor Yellow
    $response = Read-Host "是否覆盖? (y/n)"
    if ($response -ne 'y') {
        Write-Host "取消操作" -ForegroundColor Red
        exit 0
    }
    Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 解压ZIP文件
Write-Host "正在解压..." -ForegroundColor Yellow
try {
    # 先解压到临时目录
    $tempDir = "C:\node-temp"
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    
    # 重命名目录
    $extractedDir = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
    if ($extractedDir) {
        Move-Item -Path $extractedDir.FullName -Destination $extractDir -Force
        Write-Host "✅ 解压完成: $extractDir" -ForegroundColor Green
        
        # 清理临时目录
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        
        # 显示内容
        Write-Host "`n目录内容:" -ForegroundColor Cyan
        Get-ChildItem -Path $extractDir | Select-Object Name, LastWriteTime | Format-Table -AutoSize
        
        # 检查关键文件
        Write-Host "`n关键文件检查:" -ForegroundColor Cyan
        $nodeExe = Join-Path $extractDir "node.exe"
        $npmCmd = Join-Path $extractDir "npm.cmd"
        
        if (Test-Path $nodeExe) {
            Write-Host "✅ node.exe 存在" -ForegroundColor Green
            # 获取版本
            $nodeVersion = & $nodeExe --version 2>$null
            if ($nodeVersion) {
                Write-Host "  版本: $nodeVersion" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ node.exe 不存在" -ForegroundColor Red
        }
        
        if (Test-Path $npmCmd) {
            Write-Host "✅ npm.cmd 存在" -ForegroundColor Green
        } else {
            Write-Host "⚠️  npm.cmd 不存在" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "❌ 解压失败: 未找到解压目录" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ 解压过程中出错: $_" -ForegroundColor Red
    exit 1
}

# PATH设置说明
Write-Host "`n=== 下一步：设置PATH环境变量 ===" -ForegroundColor Cyan
Write-Host "请手动添加以下路径到系统PATH:" -ForegroundColor Yellow
Write-Host "  $extractDir" -ForegroundColor Green
Write-Host "`n操作步骤:" -ForegroundColor Yellow
Write-Host "1. 按 Win + R，输入 sysdm.cpl，回车"
Write-Host "2. 点击'高级'选项卡"
Write-Host "3. 点击'环境变量'"
Write-Host "4. 在'系统变量'中找到'Path'，双击编辑"
Write-Host "5. 点击'新建'，输入: $extractDir"
Write-Host "6. 点击'确定'保存所有更改"
Write-Host "`n完成后，请打开新的命令提示符窗口测试:"
Write-Host "  node --version"
Write-Host "  npm --version"

Write-Host "`n✅ 解压安装完成!" -ForegroundColor Green