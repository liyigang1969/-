# 编码修复脚本
Write-Host "=== 开始修复文件编码 ===" -ForegroundColor Cyan

$files = @(
    "work_queue.json",
    "work_state.json", 
    "HEARTBEAT.md"
)

foreach ($file in $files) {
    $fullPath = "E:\openclaw-data\.openclaw\workspace\$file"
    
    if (Test-Path $fullPath) {
        Write-Host "处理文件: $file" -ForegroundColor Green
        
        try {
            # 读取原始内容
            $content = Get-Content $fullPath -Raw -ErrorAction Stop
            
            # 保存为UTF-8无BOM
            $content | Out-File $fullPath -Encoding UTF8 -Force
            
            Write-Host "  ✅ 已重新保存为UTF-8" -ForegroundColor Green
            
            # 验证JSON文件
            if ($file -like "*.json") {
                try {
                    $test = $content | ConvertFrom-Json -ErrorAction Stop
                    Write-Host "  ✅ JSON格式有效" -ForegroundColor Green
                }
                catch {
                    Write-Host "  ❌ JSON格式无效: $_" -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "  ❌ 处理失败: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "文件不存在: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== 编码修复完成 ===" -ForegroundColor Cyan
Write-Host "现在可以重新测试自动化流程" -ForegroundColor Green