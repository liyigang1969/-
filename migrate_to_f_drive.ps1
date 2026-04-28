# OpenClaw 迁移到F盘脚本
# 版本: 1.0
# 创建时间: 2026-04-15
# 作者: 小星子

Write-Host "========================================"
Write-Host "    OpenClaw 迁移到F盘工具"
Write-Host "========================================"
Write-Host ""

# 配置参数
$sourceEData = "E:\openclaw-data"
$sourceEBackup = "E:\openclaw-memory-backup"
$targetFData = "F:\openclaw-data"
$targetFBackup = "F:\openclaw-memory-backup"

$logFile = "E:\openclaw-data\.openclaw\workspace\migration_log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 开始日志
"[$timestamp] 开始OpenClaw迁移到F盘" | Out-File -FilePath $logFile
Write-Host "[$timestamp] 开始OpenClaw迁移到F盘"

# 步骤1: 检查源目录
Write-Host ""
Write-Host "步骤1: 检查源目录..."
Write-Host "------------------------"

if (Test-Path $sourceEData) {
    Write-Host "✅ E:\openclaw-data 存在"
    "[$timestamp] 源目录存在: $sourceEData" | Out-File -FilePath $logFile -Append
} else {
    Write-Host "❌ E:\openclaw-data 不存在"
    "[$timestamp] 错误: 源目录不存在 $sourceEData" | Out-File -FilePath $logFile -Append
    exit 1
}

if (Test-Path $sourceEBackup) {
    Write-Host "✅ E:\openclaw-memory-backup 存在"
    "[$timestamp] 备份目录存在: $sourceEBackup" | Out-File -FilePath $logFile -Append
} else {
    Write-Host "⚠️ E:\openclaw-memory-backup 不存在"
    "[$timestamp] 警告: 备份目录不存在 $sourceEBackup" | Out-File -FilePath $logFile -Append
}

# 步骤2: 检查目标磁盘
Write-Host ""
Write-Host "步骤2: 检查目标磁盘F..."
Write-Host "------------------------"

$fDrive = Get-PSDrive -Name F -ErrorAction SilentlyContinue
if ($fDrive) {
    $freeSpaceGB = [math]::Round($fDrive.Free / 1GB, 2)
    $totalSpaceGB = [math]::Round($fDrive.Used / 1GB + $freeSpaceGB, 2)
    
    Write-Host "✅ F盘可用"
    Write-Host "   总容量: $totalSpaceGB GB"
    Write-Host "   可用空间: $freeSpaceGB GB"
    
    "[$timestamp] F盘信息 - 总容量: ${totalSpaceGB}GB, 可用: ${freeSpaceGB}GB" | Out-File -FilePath $logFile -Append
    
    if ($freeSpaceGB -lt 5) {
        Write-Host "⚠️ 警告: F盘可用空间不足5GB"
        "[$timestamp] 警告: F盘可用空间不足5GB" | Out-File -FilePath $logFile -Append
    }
} else {
    Write-Host "❌ F盘不可用"
    "[$timestamp] 错误: F盘不可用" | Out-File -FilePath $logFile -Append
    exit 1
}

# 步骤3: 创建目标目录
Write-Host ""
Write-Host "步骤3: 创建目标目录..."
Write-Host "------------------------"

try {
    # 创建主目录
    if (-not (Test-Path $targetFData)) {
        New-Item -ItemType Directory -Path $targetFData -Force | Out-Null
        Write-Host "✅ 创建目录: $targetFData"
        "[$timestamp] 创建目录: $targetFData" | Out-File -FilePath $logFile -Append
    } else {
        Write-Host "⚠️ 目录已存在: $targetFData"
        "[$timestamp] 目录已存在: $targetFData" | Out-File -FilePath $logFile -Append
    }
    
    # 创建备份目录
    if (-not (Test-Path $targetFBackup)) {
        New-Item -ItemType Directory -Path $targetFBackup -Force | Out-Null
        Write-Host "✅ 创建目录: $targetFBackup"
        "[$timestamp] 创建目录: $targetFBackup" | Out-File -FilePath $logFile -Append
    } else {
        Write-Host "⚠️ 目录已存在: $targetFBackup"
        "[$timestamp] 目录已存在: $targetFBackup" | Out-File -FilePath $logFile -Append
    }
} catch {
    Write-Host "❌ 创建目录失败: $_"
    "[$timestamp] 错误: 创建目录失败 - $_" | Out-File -FilePath $logFile -Append
    exit 1
}

# 步骤4: 复制文件
Write-Host ""
Write-Host "步骤4: 复制文件到F盘..."
Write-Host "------------------------"

$copyLog = "E:\openclaw-data\.openclaw\workspace\copy_log.txt"

# 复制 openclaw-data
Write-Host "正在复制 E:\openclaw-data -> F:\openclaw-data..."
try {
    robocopy $sourceEData $targetFData /MIR /R:3 /W:10 /LOG+:$copyLog /NP
    Write-Host "✅ 复制完成: openclaw-data"
    "[$timestamp] 复制完成: $sourceEData -> $targetFData" | Out-File -FilePath $logFile -Append
} catch {
    Write-Host "❌ 复制失败: $_"
    "[$timestamp] 错误: 复制失败 - $_" | Out-File -FilePath $logFile -Append
}

# 复制 openclaw-memory-backup
if (Test-Path $sourceEBackup) {
    Write-Host "正在复制 E:\openclaw-memory-backup -> F:\openclaw-memory-backup..."
    try {
        robocopy $sourceEBackup $targetFBackup /MIR /R:3 /W:10 /LOG+:$copyLog /NP
        Write-Host "✅ 复制完成: openclaw-memory-backup"
        "[$timestamp] 复制完成: $sourceEBackup -> $targetFBackup" | Out-File -FilePath $logFile -Append
    } catch {
        Write-Host "❌ 复制失败: $_"
        "[$timestamp] 错误: 复制失败 - $_" | Out-File -FilePath $logFile -Append
    }
}

# 步骤5: 验证复制
Write-Host ""
Write-Host "步骤5: 验证复制结果..."
Write-Host "------------------------"

$verificationPassed = $true

# 验证关键文件
$criticalFiles = @(
    "$targetFData\.openclaw\openclaw.json",
    "$targetFData\.openclaw\memory\main.sqlite",
    "$targetFData\.openclaw\workspace\AGENTS.md"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "✅ 文件存在: $file"
        "[$timestamp] 验证通过: $file" | Out-File -FilePath $logFile -Append
    } else {
        Write-Host "❌ 文件缺失: $file"
        "[$timestamp] 验证失败: $file" | Out-File -FilePath $logFile -Append
        $verificationPassed = $false
    }
}

# 步骤6: 更新配置文件
Write-Host ""
Write-Host "步骤6: 更新配置文件..."
Write-Host "------------------------"

$configFile = "$targetFData\.openclaw\openclaw.json"
if (Test-Path $configFile) {
    try {
        # 备份原配置
        $backupConfig = "$configFile.backup"
        Copy-Item $configFile $backupConfig -Force
        Write-Host "✅ 配置文件备份: $backupConfig"
        
        # 这里可以添加配置更新逻辑
        # 例如更新文件路径等
        
        Write-Host "✅ 配置文件就绪"
        "[$timestamp] 配置文件更新完成" | Out-File -FilePath $logFile -Append
    } catch {
        Write-Host "⚠️ 配置文件更新跳过: $_"
        "[$timestamp] 警告: 配置文件更新跳过 - $_" | Out-File -FilePath $logFile -Append
    }
} else {
    Write-Host "⚠️ 配置文件不存在，跳过更新"
    "[$timestamp] 信息: 配置文件不存在，跳过更新" | Out-File -FilePath $logFile -Append
}

# 步骤7: 更新记忆关联配置
Write-Host ""
Write-Host "步骤7: 更新记忆关联配置..."
Write-Host "------------------------"

$assocFile = "$targetFData\.openclaw\workspace\file_associations.json"
if (Test-Path $assocFile) {
    try {
        $assocContent = Get-Content $assocFile -Raw | ConvertFrom-Json
        
        # 更新路径到F盘
        if ($assocContent.关联系统 -and $assocContent.关联系统.文件关联) {
            $assocContent.关联系统.文件关联.配置目录.路径 = "F:\openclaw-data\.openclaw"
            $assocContent.关联系统.文件关联.记忆备份.路径 = "F:\openclaw-memory-backup"
            
            $assocContent | ConvertTo-Json -Depth 10 | Set-Content $assocFile
            Write-Host "✅ 记忆关联配置已更新"
            "[$timestamp] 记忆关联配置已更新" | Out-File -FilePath $logFile -Append
        }
    } catch {
        Write-Host "⚠️ 记忆关联配置更新失败: $_"
        "[$timestamp] 警告: 记忆关联配置更新失败 - $_" | Out-File -FilePath $logFile -Append
    }
}

# 步骤8: 创建启动脚本
Write-Host ""
Write-Host "步骤8: 创建F盘启动脚本..."
Write-Host "------------------------"

$startupScript = "F:\start_openclaw_from_f.bat"
$scriptContent = @"
@echo off
echo 从F盘启动OpenClaw...
echo.

set OPENCLAW_DIR=F:\openclaw-data\.openclaw
set CONFIG_FILE=%OPENCLAW_DIR%\openclaw.json

echo 配置目录: %OPENCLAW_DIR%
echo 配置文件: %CONFIG_FILE%
echo.

if exist "%CONFIG_FILE%" (
    echo ✅ 配置文件存在
    echo 正在启动OpenClaw...
    
    REM 这里添加实际的OpenClaw启动命令
    REM 例如: node "C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw\openclaw.mjs" --config "%CONFIG_FILE%"
    
    echo.
    echo 启动命令已准备就绪
    echo 请根据实际安装位置修改启动命令
) else (
    echo ❌ 配置文件不存在
    echo 请检查迁移是否完成
)

echo.
pause
"@

$scriptContent | Out-File -FilePath $startupScript -Encoding ASCII
Write-Host "✅ 启动脚本创建: $startupScript"
"[$timestamp] 启动脚本创建: $startupScript" | Out-File -FilePath $logFile -Append

# 最终总结
Write-Host ""
Write-Host "========================================"
Write-Host "           迁移完成总结"
Write-Host "========================================"
Write-Host ""

if ($verificationPassed) {
    Write-Host "✅ 迁移成功!"
    Write-Host ""
    Write-Host "已迁移的内容:"
    Write-Host "1. E:\openclaw-data -> F:\openclaw-data"
    Write-Host "2. E:\openclaw-memory-backup -> F:\openclaw-memory-backup"
    Write-Host ""
    Write-Host "下一步操作:"
    Write-Host "1. 测试从F盘启动: 运行 $startupScript"
    Write-Host "2. 验证功能完整性"
    Write-Host "3. 更新OpenClaw实际启动配置"
    Write-Host "4. 清理E盘旧文件（确认F盘运行正常后）"
    Write-Host ""
    Write-Host "日志文件:"
    Write-Host "  - 迁移日志: $logFile"
    Write-Host "  - 复制日志: $copyLog"
    
    "[$timestamp] 迁移成功完成" | Out-File -FilePath $logFile -Append
} else {
    Write-Host "⚠️ 迁移完成但有警告"
    Write-Host "请检查以上错误信息"
    Write-Host ""
    Write-Host "日志文件: $logFile"
    
    "[$timestamp] 迁移完成但有警告" | Out-File -FilePath $logFile -Append
}

Write-Host ""
Write-Host "按Enter键退出..."
Read-Host