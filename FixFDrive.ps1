Write-Host "=== F盘OpenClaw修复脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 1. 检查磁盘空间
Write-Host "[1/6] 检查磁盘空间..." -ForegroundColor Yellow
$drive = Get-PSDrive F
Write-Host "F盘可用空间: $([math]::Round($drive.Free/1GB,2)) GB" -ForegroundColor Green
Write-Host ""

# 2. 备份原始配置
Write-Host "[2/6] 备份原始配置..." -ForegroundColor Yellow
$backupDir = "F:\openclaw-backup-before-fix"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}
if (Test-Path "F:\openclaw-data\.openclaw") {
    Copy-Item -Path "F:\openclaw-data\.openclaw\*" -Destination $backupDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "备份完成: $backupDir" -ForegroundColor Green
} else {
    Write-Host "警告: F:\openclaw-data\.openclaw 不存在" -ForegroundColor Yellow
}
Write-Host ""

# 3. 复制Node.js运行时
Write-Host "[3/6] 复制Node.js运行时..." -ForegroundColor Yellow
$runtimeDir = "F:\runtime"
if (-not (Test-Path $runtimeDir)) {
    New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
}
if (Test-Path "E:\runtime\node.exe") {
    Copy-Item -Path "E:\runtime\node.exe" -Destination "$runtimeDir\node.exe" -Force
    if (Test-Path "$runtimeDir\node.exe") {
        Write-Host "Node.js复制成功" -ForegroundColor Green
    } else {
        Write-Host "错误: Node.js复制失败" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "错误: E:\runtime\node.exe 不存在" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 4. 复制完整配置
Write-Host "[4/6] 复制完整配置..." -ForegroundColor Yellow
$targetConfigDir = "F:\openclaw-data\.openclaw"
if (-not (Test-Path $targetConfigDir)) {
    New-Item -ItemType Directory -Path $targetConfigDir -Force | Out-Null
}
if (Test-Path "E:\openclaw-data\.openclaw") {
    # 先复制主配置文件
    Copy-Item -Path "E:\openclaw-data\.openclaw\openclaw.json" -Destination $targetConfigDir -Force
    Write-Host "主配置文件复制完成" -ForegroundColor Green
    
    # 复制其他重要目录
    $importantDirs = @("agents", "cron", "identity", "memory", "workspace", "extensions")
    foreach ($dir in $importantDirs) {
        $sourceDir = "E:\openclaw-data\.openclaw\$dir"
        $destDir = "$targetConfigDir\$dir"
        if (Test-Path $sourceDir) {
            Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  - $dir 目录复制完成" -ForegroundColor Green
        }
    }
} else {
    Write-Host "错误: E:\openclaw-data\.openclaw 不存在" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 5. 启用微信插件
Write-Host "[5/6] 启用微信插件..." -ForegroundColor Yellow
$disabledPlugin = "F:\openclaw-data\.openclaw\extensions\openclaw-weixin.disabled"
$enabledPlugin = "F:\openclaw-data\.openclaw\extensions\openclaw-weixin"
if (Test-Path $disabledPlugin) {
    Rename-Item -Path $disabledPlugin -NewName "openclaw-weixin" -Force
    Write-Host "微信插件已启用" -ForegroundColor Green
} elseif (Test-Path $enabledPlugin) {
    Write-Host "微信插件已启用" -ForegroundColor Green
} else {
    Write-Host "微信插件不存在，跳过" -ForegroundColor Yellow
}
Write-Host ""

# 6. 创建F盘启动脚本
Write-Host "[6/6] 创建F盘启动脚本..." -ForegroundColor Yellow
$startScript = @'
@echo off
echo 正在启动F盘OpenClaw...
echo.

if exist "F:\runtime\node.exe" (
    echo 找到Node.js运行时，正在启动网关...
    start "OpenClaw Gateway" "F:\runtime\node.exe" "F:\OpenClaw_System\program\openclaw.mjs" gateway
) else (
    echo 错误: 未找到Node.js运行时
    echo 请确保F:\runtime\node.exe存在
)

echo.
echo 启动脚本执行完成
pause
'@
Set-Content -Path "F:\启动OpenClaw.bat" -Value $startScript -Encoding ASCII
Write-Host "F盘启动脚本创建完成: F:\启动OpenClaw.bat" -ForegroundColor Green
Write-Host ""

Write-Host "=== 修复完成！ ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "修复项目：" -ForegroundColor Yellow
Write-Host "1. ✅ Node.js运行时已复制到 F:\runtime\" -ForegroundColor Green
Write-Host "2. ✅ 完整配置已复制到 F:\openclaw-data\.openclaw\" -ForegroundColor Green
Write-Host "3. ✅ 微信插件已启用" -ForegroundColor Green
Write-Host "4. ✅ F盘启动脚本已创建" -ForegroundColor Green
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "1. 双击 F:\启动OpenClaw.bat 启动F盘网关" -ForegroundColor White
Write-Host "2. 检查控制UI连接状态" -ForegroundColor White
Write-Host "3. 验证API配置" -ForegroundColor White
Write-Host ""
Write-Host "原始配置备份在：F:\openclaw-backup-before-fix\" -ForegroundColor Gray
Write-Host ""