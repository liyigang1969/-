# Node.js安装脚本
$msiPath = "C:\Users\lenovo\Downloads\node-v22.22.2-x64.msi"

Write-Host "=== Node.js安装程序 ===" -ForegroundColor Cyan

# 检查安装文件是否存在
if (-not (Test-Path $msiPath)) {
    Write-Host "安装文件不存在: $msiPath" -ForegroundColor Red
    Write-Host "请先下载Node.js安装程序" -ForegroundColor Yellow
    exit 1
}

Write-Host "找到安装文件: $msiPath" -ForegroundColor Green
Write-Host "文件大小: $([math]::Round((Get-Item $msiPath).Length / 1MB, 2)) MB" -ForegroundColor Green

# 安装选项
Write-Host "`n安装选项:" -ForegroundColor Cyan
Write-Host "1. 默认安装 (推荐)"
Write-Host "2. 自定义安装"
Write-Host "3. 仅添加到PATH"

$choice = Read-Host "请选择安装方式 (1-3)"

# 安装命令
$installArgs = "/i `"$msiPath`" /quiet"

switch ($choice) {
    "1" {
        # 默认安装：安装所有功能并添加到PATH
        $installArgs += " ADDLOCAL=NodeRuntime,npm,DocumentationShortcuts,EnvironmentPathNode,EnvironmentPathNpm"
        Write-Host "选择: 默认安装" -ForegroundColor Green
    }
    "2" {
        # 自定义安装
        Write-Host "自定义安装选项:" -ForegroundColor Yellow
        Write-Host "- Node.js运行时 (必需)"
        Write-Host "- npm包管理器 (推荐)"
        Write-Host "- 添加到系统PATH (必需)"
        Write-Host "- 在线文档快捷方式 (可选)"
        
        $addLocal = "NodeRuntime,EnvironmentPathNode"
        if ((Read-Host "安装npm? (y/n)") -eq "y") { $addLocal += ",npm,EnvironmentPathNpm" }
        if ((Read-Host "添加快捷方式? (y/n)") -eq "y") { $addLocal += ",DocumentationShortcuts" }
        
        $installArgs += " ADDLOCAL=$addLocal"
        Write-Host "选择: 自定义安装" -ForegroundColor Green
    }
    "3" {
        # 仅添加到PATH（如果已安装）
        Write-Host "检查已安装的Node.js..." -ForegroundColor Yellow
        $nodePath = Get-Command node -ErrorAction SilentlyContinue
        if ($nodePath) {
            Write-Host "Node.js已安装: $($nodePath.Source)" -ForegroundColor Green
            Write-Host "将尝试更新PATH环境变量..." -ForegroundColor Yellow
            # 这里可以添加更新PATH的逻辑
        } else {
            Write-Host "未找到Node.js，请先安装" -ForegroundColor Red
            exit 1
        }
        return
    }
    default {
        Write-Host "无效选择，使用默认安装" -ForegroundColor Yellow
        $installArgs += " ADDLOCAL=NodeRuntime,npm,DocumentationShortcuts,EnvironmentPathNode,EnvironmentPathNpm"
    }
}

# 执行安装
Write-Host "`n开始安装Node.js..." -ForegroundColor Green
Write-Host "安装命令: msiexec $installArgs" -ForegroundColor Gray

try {
    # 使用msiexec安装
    $process = Start-Process msiexec -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host "Node.js安装成功!" -ForegroundColor Green
        
        # 验证安装
        Write-Host "`n验证安装..." -ForegroundColor Cyan
        $nodeVersion = node --version 2>$null
        $npmVersion = npm --version 2>$null
        
        if ($nodeVersion) {
            Write-Host "Node.js版本: $nodeVersion" -ForegroundColor Green
        } else {
            Write-Host "Node.js未正确安装" -ForegroundColor Red
        }
        
        if ($npmVersion) {
            Write-Host "npm版本: $npmVersion" -ForegroundColor Green
        } else {
            Write-Host "npm未正确安装" -ForegroundColor Yellow
        }
        
        # 测试OpenClaw
        Write-Host "`n测试OpenClaw..." -ForegroundColor Cyan
        $openclawPath = "C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw"
        if (Test-Path $openclawPath) {
            Push-Location $openclawPath
            $openclawVersion = node openclaw.mjs --version 2>$null
            Pop-Location
            
            if ($openclawVersion) {
                Write-Host "OpenClaw版本: $openclawVersion" -ForegroundColor Green
                Write-Host "OpenClaw可以正常运行!" -ForegroundColor Green
            } else {
                Write-Host "OpenClaw运行测试失败" -ForegroundColor Yellow
            }
        }
        
    } else {
        Write-Host "安装失败，退出代码: $($process.ExitCode)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "安装过程中出错: $_" -ForegroundColor Red
}

Write-Host "`n安装完成!" -ForegroundColor Cyan
Write-Host "可能需要重启命令行窗口以使PATH更改生效" -ForegroundColor Yellow