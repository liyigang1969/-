# OpenClaw 记忆关联启动脚本 (PowerShell版本)

Write-Host "========================================"
Write-Host "     OpenClaw 记忆关联启动脚本"
Write-Host "========================================"
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = "E:\openclaw-data\.openclaw\workspace\startup_log.txt"
$configFile = "E:\openclaw-data\.openclaw\workspace\file_associations.json"
$indexFile = "E:\openclaw-data\.openclaw\workspace\memory_index.txt"

# 开始日志
"[$timestamp] 开始OpenClaw记忆关联启动" | Out-File -FilePath $logFile -Append
Write-Host "正在加载关联配置文件..."

# 检查配置文件
if (Test-Path $configFile) {
    Write-Host "✅ 关联配置文件存在"
    "[$timestamp] 加载关联配置文件: $configFile" | Out-File -FilePath $logFile -Append
} else {
    Write-Host "❌ 关联配置文件不存在"
    "[$timestamp] 错误: 关联配置文件不存在" | Out-File -FilePath $logFile -Append
}

Write-Host ""
Write-Host "正在检查关联文件..."
Write-Host ""

# 1. 检查核心安装
$coreDir = "C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw"
if (Test-Path $coreDir) {
    Write-Host "✅ 核心安装目录: $coreDir"
    "[$timestamp] 核心安装目录存在: $coreDir" | Out-File -FilePath $logFile -Append
    
    # 检查关键文件
    $packageJson = "$coreDir\package.json"
    $openclawMjs = "$coreDir\openclaw.mjs"
    
    if (Test-Path $packageJson) {
        Write-Host "  ✓ package.json 存在"
        # 获取版本信息
        try {
            $package = Get-Content $packageJson | ConvertFrom-Json
            $version = $package.version
            Write-Host "    版本: $version"
        } catch {
            Write-Host "    版本: 无法读取"
        }
    } else {
        Write-Host "  ✗ package.json 缺失"
    }
    
    if (Test-Path $openclawMjs) {
        Write-Host "  ✓ openclaw.mjs 存在"
    } else {
        Write-Host "  ✗ openclaw.mjs 缺失"
    }
} else {
    Write-Host "❌ 核心安装目录不存在"
    "[$timestamp] 错误: 核心安装目录不存在" | Out-File -FilePath $logFile -Append
}

Write-Host ""

# 2. 检查配置目录
$configDir = "E:\openclaw-data\.openclaw"
if (Test-Path $configDir) {
    Write-Host "✅ 配置目录: $configDir"
    "[$timestamp] 配置目录存在: $configDir" | Out-File -FilePath $logFile -Append
    
    $configJson = "$configDir\openclaw.json"
    $memoryDb = "$configDir\memory\main.sqlite"
    
    if (Test-Path $configJson) {
        Write-Host "  ✓ openclaw.json 存在"
        $configSize = (Get-Item $configJson).Length
        Write-Host "    大小: $($configSize) 字节"
    } else {
        Write-Host "  ✗ openclaw.json 缺失"
    }
    
    if (Test-Path $memoryDb) {
        Write-Host "  ✓ 记忆数据库存在"
        $dbSize = (Get-Item $memoryDb).Length
        Write-Host "    大小: $([math]::Round($dbSize/1024, 2)) KB"
    } else {
        Write-Host "  ✗ 记忆数据库缺失"
    }
} else {
    Write-Host "❌ 配置目录不存在"
    "[$timestamp] 错误: 配置目录不存在" | Out-File -FilePath $logFile -Append
}

Write-Host ""

# 3. 检查记忆备份
$backupDir = "E:\openclaw-memory-backup"
if (Test-Path $backupDir) {
    Write-Host "✅ 记忆备份目录: $backupDir"
    "[$timestamp] 记忆备份目录存在: $backupDir" | Out-File -FilePath $logFile -Append
    
    $backupDb = "$backupDir\memory-database\main.sqlite"
    $restoreScript = "$backupDir\restore_memory.bat"
    
    if (Test-Path $backupDb) {
        Write-Host "  ✓ 备份记忆数据库存在"
        $backupSize = (Get-Item $backupDb).Length
        Write-Host "    大小: $([math]::Round($backupSize/1024, 2)) KB"
    } else {
        Write-Host "  ✗ 备份记忆数据库缺失"
    }
    
    if (Test-Path $restoreScript) {
        Write-Host "  ✓ 恢复工具存在"
    } else {
        Write-Host "  ✗ 恢复工具缺失"
    }
} else {
    Write-Host "⚠️ 记忆备份目录不存在"
    "[$timestamp] 警告: 记忆备份目录不存在" | Out-File -FilePath $logFile -Append
}

Write-Host ""

# 4. 检查资源包
$packageDir = "D:\OpenClaw_Packages"
if (Test-Path $packageDir) {
    Write-Host "✅ 资源包目录: $packageDir"
    "[$timestamp] 资源包目录存在: $packageDir" | Out-File -FilePath $logFile -Append
    
    # 检查子目录
    $subDirs = Get-ChildItem -Path $packageDir -Directory
    if ($subDirs) {
        Write-Host "  包含子目录:"
        foreach ($dir in $subDirs) {
            Write-Host "    • $($dir.Name)"
        }
    }
} else {
    Write-Host "⚠️ 资源包目录不存在"
    "[$timestamp] 信息: 资源包目录不存在" | Out-File -FilePath $logFile -Append
}

Write-Host ""
Write-Host "正在创建记忆索引..."
"[$timestamp] 开始创建记忆索引" | Out-File -FilePath $logFile -Append

# 创建记忆索引
$indexContent = @"
# OpenClaw 记忆索引
# 生成时间: $timestamp

## 关联文件系统
1. 核心安装: $coreDir
2. 配置目录: $configDir
3. 记忆备份: $backupDir
4. 资源包: $packageDir

## 关键文件状态
核心版本: $(if (Test-Path "$coreDir\package.json") { try { (Get-Content "$coreDir\package.json" | ConvertFrom-Json).version } catch { "未知" } } else { "未找到" })
配置文件: $(if (Test-Path "$configDir\openclaw.json") { "正常" } else { "缺失" })
记忆数据库: $(if (Test-Path "$configDir\memory\main.sqlite") { "正常" } else { "缺失" })
工作区文件: $(if (Test-Path "$configDir\workspace\") { "正常" } else { "缺失" })

## 系统信息
OpenClaw版本: 2026.4.14
检查时间: $timestamp
状态: 关联完成
"@

$indexContent | Out-File -FilePath $indexFile -Encoding UTF8
Write-Host "✅ 记忆索引创建完成: $indexFile"
"[$timestamp] 记忆索引创建完成: $indexFile" | Out-File -FilePath $logFile -Append

Write-Host ""
Write-Host "========================================"
Write-Host "           启动关联完成!"
Write-Host "========================================"
Write-Host ""
Write-Host "已关联的文件系统:"
Write-Host "1. 核心安装 - 运行OpenClaw"
Write-Host "2. 配置目录 - 个人配置和记忆"
Write-Host "3. 记忆备份 - 安全备份"
Write-Host "4. 资源包 - 额外资源"
Write-Host ""
Write-Host "使用命令:"
Write-Host "  !files    - 查看关联文件"
Write-Host "  !backup   - 执行备份"
Write-Host "  !restore  - 恢复记忆"
Write-Host "  !info     - 系统信息"
Write-Host ""
Write-Host "详细日志: $logFile"
Write-Host "记忆索引: $indexFile"
Write-Host ""
"[$timestamp] OpenClaw记忆关联启动完成" | Out-File -FilePath $logFile -Append

Write-Host "按Enter键继续..."
Read-Host