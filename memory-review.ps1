# OpenClaw记忆回顾脚本
# 在OpenClaw启动时运行，显示重要记忆信息

param(
    [string]$MemoryPath = "E:\openclaw-data\.openclaw\workspace\memory"
)

function Show-Section {
    param([string]$Title, [string]$Color = "Cyan")
    Write-Host "`n" + ("=" * 60) -ForegroundColor $Color
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Host ("=" * 60) -ForegroundColor $Color
}

function Show-FilePreview {
    param([string]$FilePath, [string]$Description, [int]$Lines = 5)
    
    if (Test-Path $FilePath) {
        Write-Host "`n📄 $Description" -ForegroundColor Green
        try {
            $content = Get-Content $FilePath -TotalCount $Lines
            foreach ($line in $content) {
                Write-Host "   $line" -ForegroundColor Gray
            }
            if ((Get-Content $FilePath | Measure-Object -Line).Lines -gt $Lines) {
                Write-Host "   ..." -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "   (无法读取文件)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n📄 $Description" -ForegroundColor Yellow
        Write-Host "   (文件不存在)" -ForegroundColor DarkGray
    }
}

# 显示标题
Write-Host "`n" + ("*" * 70) -ForegroundColor Magenta
Write-Host "                  🧠 OPENCLAW 记忆回顾系统" -ForegroundColor Magenta
Write-Host "                  " + (Get-Date -Format "yyyy-MM-dd HH:mm") -ForegroundColor Magenta
Write-Host ("*" * 70) -ForegroundColor Magenta

# 1. 今日记录
$todayFile = "$MemoryPath\daily\$(Get-Date -Format 'yyyy-MM-dd').md"
Show-FilePreview -FilePath $todayFile -Description "今日记录" -Lines 8

# 2. 昨日回顾
$yesterdayFile = "$MemoryPath\daily\$(Get-Date (Get-Date).AddDays(-1) -Format 'yyyy-MM-dd').md"
Show-FilePreview -FilePath $yesterdayFile -Description "昨日回顾" -Lines 5

# 3. 今日重点
$dailyFocus = "$MemoryPath\goals\daily-focus.md"
Show-FilePreview -FilePath $dailyFocus -Description "今日重点" -Lines 10

# 4. 进行中项目
$openclawProject = "$MemoryPath\projects\openclaw-setup.md"
Show-FilePreview -FilePath $openclawProject -Description "OpenClaw项目" -Lines 6

# 5. 快速搜索提示
Show-Section -Title "🔍 快速记忆搜索" -Color "Blue"
Write-Host "   使用命令: openclaw memory search '关键词'" -ForegroundColor Cyan
Write-Host "   示例: openclaw memory search 'OpenClaw配置'" -ForegroundColor Cyan
Write-Host "   示例: openclaw memory search '今日目标'" -ForegroundColor Cyan

# 6. 记忆统计
Show-Section -Title "📊 记忆统计" -Color "Green"
try {
    $dailyFiles = Get-ChildItem "$MemoryPath\daily\*.md" | Measure-Object
    $projectFiles = Get-ChildItem "$MemoryPath\projects\*.md" | Measure-Object
    $totalFiles = $dailyFiles.Count + $projectFiles.Count
    
    Write-Host "   每日记录: $($dailyFiles.Count) 个文件" -ForegroundColor Cyan
    Write-Host "   项目文档: $($projectFiles.Count) 个文件" -ForegroundColor Cyan
    Write-Host "   总计: $totalFiles 个记忆文件" -ForegroundColor Green
} catch {
    Write-Host "   无法统计文件" -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Magenta
Write-Host "  记忆回顾完成，开始工作吧！ 🚀" -ForegroundColor Magenta
Write-Host ("=" * 60) -ForegroundColor Magenta