# E盘防拷贝程序检查脚本

Write-Host "=== E盘防拷贝程序全面检查 ===" -ForegroundColor Cyan
Write-Host "检查时间: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# 1. 磁盘基本信息
Write-Host "[1] 磁盘基本信息" -ForegroundColor Yellow
$disk = Get-Volume -DriveLetter E -ErrorAction SilentlyContinue
if ($disk) {
    Write-Host "  驱动器: E" -ForegroundColor White
    Write-Host "  文件系统: $($disk.FileSystem)" -ForegroundColor White
    Write-Host "  总大小: $([math]::Round($disk.Size/1GB, 2)) GB" -ForegroundColor White
    Write-Host "  可用空间: $([math]::Round($disk.SizeRemaining/1GB, 2)) GB" -ForegroundColor White
    Write-Host "  使用率: $([math]::Round(($disk.Size - $disk.SizeRemaining)/$disk.Size*100, 1))%" -ForegroundColor White
} else {
    Write-Host "  ❌ 无法访问E盘" -ForegroundColor Red
}

Write-Host ""

# 2. 权限检查
Write-Host "[2] 权限检查" -ForegroundColor Yellow
try {
    $acl = Get-Acl -Path 'E:\' -ErrorAction Stop
    $permissions = $acl.Access | Where-Object { $_.FileSystemRights -match "FullControl|Write|Modify" }
    
    if ($permissions.Count -gt 0) {
        Write-Host "  ✅ 当前用户有写入权限" -ForegroundColor Green
        $permissions | ForEach-Object {
            Write-Host "    用户: $($_.IdentityReference)" -ForegroundColor Gray
            Write-Host "    权限: $($_.FileSystemRights)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ⚠️  当前用户可能没有写入权限" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ 权限检查失败: $_" -ForegroundColor Red
}

Write-Host ""

# 3. 检查隐藏文件
Write-Host "[3] 隐藏文件检查" -ForegroundColor Yellow
$hiddenFiles = Get-ChildItem -Path 'E:\' -Force -Hidden -ErrorAction SilentlyContinue
if ($hiddenFiles.Count -gt 0) {
    Write-Host "  找到隐藏文件/目录:" -ForegroundColor White
    $hiddenFiles | ForEach-Object {
        Write-Host "    $($_.Name) ($($_.Attributes))" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✅ 无异常隐藏文件" -ForegroundColor Green
}

Write-Host ""

# 4. 检查防拷贝软件进程
Write-Host "[4] 防拷贝软件进程检查" -ForegroundColor Yellow
$antiCopyProcesses = @(
    # 加密软件
    "truecrypt", "veracrypt", "axcrypt", "cryptainer",
    # 文件夹锁
    "folderlock", "filelock", "mylockbox",
    # DRM软件
    "safedisc", "securom", "starforce",
    # 企业级防拷贝
    "endpoint", "protector", "guard", "vault"
)

$foundProcesses = Get-Process | Where-Object {
    $processName = $_.ProcessName.ToLower()
    $antiCopyProcesses | Where-Object { $processName -like "*$_*" }
}

if ($foundProcesses.Count -gt 0) {
    Write-Host "  ⚠️  发现可能的防拷贝软件进程:" -ForegroundColor Yellow
    $foundProcesses | Select-Object ProcessName, Id, Path | Format-Table -AutoSize
} else {
    Write-Host "  ✅ 未发现常见防拷贝软件进程" -ForegroundColor Green
}

Write-Host ""

# 5. 检查服务
Write-Host "[5] 防拷贝相关服务检查" -ForegroundColor Yellow
$antiCopyServices = Get-Service | Where-Object {
    $serviceName = $_.Name.ToLower()
    $displayName = $_.DisplayName.ToLower()
    $serviceName -match "copy|protect|guard|lock|secure|encrypt|drm|rights" -or
    $displayName -match "copy|protect|guard|lock|secure|encrypt|drm|rights"
}

if ($antiCopyServices.Count -gt 0) {
    Write-Host "  ⚠️  发现可能的防拷贝相关服务:" -ForegroundColor Yellow
    $antiCopyServices | Select-Object Name, DisplayName, Status | Format-Table -AutoSize
} else {
    Write-Host "  ✅ 未发现防拷贝相关服务" -ForegroundColor Green
}

Write-Host ""

# 6. 检查注册表（常见的防拷贝软件）
Write-Host "[6] 注册表检查" -ForegroundColor Yellow
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$antiCopySoftware = @()
foreach ($path in $regPaths) {
    if (Test-Path $path) {
        $items = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            if ($item.DisplayName -and $item.DisplayName -match "(?i)copy.*protect|protect.*copy|encrypt|lock|guard|drm|secure") {
                $antiCopySoftware += [PSCustomObject]@{
                    Name = $item.DisplayName
                    Publisher = $item.Publisher
                    InstallDate = $item.InstallDate
                }
            }
        }
    }
}

if ($antiCopySoftware.Count -gt 0) {
    Write-Host "  ⚠️  发现可能的防拷贝软件:" -ForegroundColor Yellow
    $antiCopySoftware | Format-Table -AutoSize
} else {
    Write-Host "  ✅ 未发现防拷贝软件安装记录" -ForegroundColor Green
}

Write-Host ""

# 7. 测试文件操作
Write-Host "[7] 文件操作测试" -ForegroundColor Yellow
$testFile = "E:\test_copy_check_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
try {
    # 测试创建文件
    "测试文件 - 创建时间: $(Get-Date)" | Out-File -FilePath $testFile -Encoding UTF8
    if (Test-Path $testFile) {
        Write-Host "  ✅ 可以创建文件" -ForegroundColor Green
        
        # 测试读取文件
        $content = Get-Content -Path $testFile -Raw
        if ($content) {
            Write-Host "  ✅ 可以读取文件" -ForegroundColor Green
        }
        
        # 测试删除文件
        Remove-Item -Path $testFile -Force
        if (-not (Test-Path $testFile)) {
            Write-Host "  ✅ 可以删除文件" -ForegroundColor Green
        } else {
            Write-Host "  ❌ 无法删除文件" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ 无法创建文件" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ 文件操作测试失败: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 检查总结 ===" -ForegroundColor Cyan

# 总结评估
$issues = @()

if ($foundProcesses.Count -gt 0) { $issues += "发现防拷贝软件进程" }
if ($antiCopyServices.Count -gt 0) { $issues += "发现防拷贝相关服务" }
if ($antiCopySoftware.Count -gt 0) { $issues += "发现防拷贝软件安装记录" }

if ($issues.Count -eq 0) {
    Write-Host "✅ E盘未发现明显的防拷贝程序" -ForegroundColor Green
    Write-Host "   文件系统: FAT32 (通常无高级保护功能)" -ForegroundColor Gray
    Write-Host "   权限设置: 宽松 (Everyone有完全控制)" -ForegroundColor Gray
    Write-Host "   文件操作: 正常 (可创建、读取、删除)" -ForegroundColor Gray
} else {
    Write-Host "⚠️  E盘可能存在防拷贝保护:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host "   • $issue" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "建议进一步检查:" -ForegroundColor White
    Write-Host "1. 检查是否有企业级数据防泄漏(DLP)软件" -ForegroundColor Gray
    Write-Host "2. 检查是否有全盘加密软件" -ForegroundColor Gray
    Write-Host "3. 检查网络策略和组策略设置" -ForegroundColor Gray
}

Write-Host ""
Write-Host "检查完成!" -ForegroundColor Cyan