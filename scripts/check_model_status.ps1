# Скрипт для проверки статуса модели

$MODEL_PATH = "assets\aka\models\model_v1.bin.xz"
$TEMP_PATH = "assets\aka\models\model_v1_temp.gguf"
$TEMP_XZ_PATH = "assets\aka\models\model_v1_temp.gguf.xz"

Write-Host "=== Model Status Check ===" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $MODEL_PATH) {
    $size = (Get-Item $MODEL_PATH).Length
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "✅ SUCCESS: Compressed model exists!" -ForegroundColor Green
    Write-Host "   File: $MODEL_PATH" -ForegroundColor White
    Write-Host "   Size: $sizeMB MB" -ForegroundColor White
    Write-Host ""
    Write-Host "Model is ready to use in the app!" -ForegroundColor Green
    exit 0
}

# Проверяем промежуточный сжатый файл
if (Test-Path $TEMP_XZ_PATH) {
    $size = (Get-Item $TEMP_XZ_PATH).Length
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "⏳ Compression in progress or completed (needs renaming)" -ForegroundColor Yellow
    Write-Host "   Compressed file: $TEMP_XZ_PATH" -ForegroundColor White
    Write-Host "   Size: $sizeMB MB" -ForegroundColor White
    Write-Host ""
    Write-Host "The compressed file exists but needs to be renamed." -ForegroundColor Yellow
    Write-Host "Run: .\scripts\compress_model.ps1" -ForegroundColor Cyan
    exit 1
}

# Проверяем скачанный файл
if (Test-Path $TEMP_PATH) {
    $tempSize = (Get-Item $TEMP_PATH).Length
    $tempSizeMB = [math]::Round($tempSize / 1MB, 2)
    $expectedSize = 1470  # ~1.47GB для Q3_K_S (unsloth)
    $progress = [math]::Round(($tempSizeMB / $expectedSize) * 100, 1)
    $lastWrite = (Get-Item $TEMP_PATH).LastWriteTime
    $timeSinceUpdate = (Get-Date) - $lastWrite
    
    if ($progress -ge 100) {
        Write-Host "✅ Download complete!" -ForegroundColor Green
        Write-Host "   Downloaded: $tempSizeMB MB" -ForegroundColor White
        Write-Host "   Last update: $lastWrite" -ForegroundColor White
        Write-Host ""
        
        if ($timeSinceUpdate.TotalMinutes -gt 2) {
            Write-Host "⚠️ Compression has not started automatically." -ForegroundColor Yellow
            Write-Host "   Time since download: $([math]::Round($timeSinceUpdate.TotalMinutes,1)) minutes" -ForegroundColor White
            Write-Host ""
            Write-Host "Run compression manually:" -ForegroundColor Cyan
            Write-Host "   .\scripts\compress_model.ps1" -ForegroundColor White
        } else {
            Write-Host "⏳ Waiting for compression to start..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "⏳ Download in progress:" -ForegroundColor Cyan
        Write-Host "   Downloaded: $tempSizeMB MB" -ForegroundColor White
        Write-Host "   Expected: ~$expectedSize MB" -ForegroundColor White
        Write-Host "   Progress: $progress%" -ForegroundColor White
        Write-Host ""
        Write-Host "Please wait for download to complete..." -ForegroundColor Yellow
    }
} else {
    Write-Host "⏳ No download in progress." -ForegroundColor Yellow
    Write-Host "Run: .\scripts\download_model_resumable.ps1" -ForegroundColor Cyan
}

exit 1
