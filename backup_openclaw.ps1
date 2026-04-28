# OpenClaw配置备份脚本
Write-Host "========================================"
Write-Host "     OpenClaw 配置备份工具"
Write-Host "========================================"
Write-Host ""

$sourceDir = "E:\openclaw-data\.openclaw"
$backupDir = "E:\openclaw-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"

Write-Host "源目录: $sourceDir"
Write-Host "备份目录: $backupDir"
Write-Host ""

if (-not (Test-Path $sourceDir)) {
    Write-Host "错误: 源目录不存在!"
    Read-Host "按Enter键退出"
    exit 1
}

Write-Host "正在创建备份目录..."
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

Write-Host "正在备份配置文件..."
Copy-Item -Path "$sourceDir\*" -Destination $backupDir -Recurse -Force

Write-Host ""
Write-Host "========================================"
Write-Host "           备份完成!"
Write-Host "========================================"
Write-Host ""
Write-Host "已备份到: $backupDir"
Write-Host ""
Write-Host "重要文件:"
Write-Host "  - 配置: $backupDir\config.json"
Write-Host "  - 记忆: $backupDir\MEMORY.md"
Write-Host "  - 工作区: $backupDir\workspace\"
Write-Host "  - 扩展: $backupDir\extensions\"
Write-Host ""
Read-Host "按Enter键继续"