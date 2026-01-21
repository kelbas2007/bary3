# Скрипт для мониторинга скачивания модели

$MODEL_DIR = "assets\aka\models"
$TEMP_FILE = Join-Path $MODEL_DIR "model_v1_temp.gguf"
$FINAL_FILE = Join-Path $MODEL_DIR "model_v1.bin.xz"

Write-Host "=== Мониторинг скачивания модели Q2_K ===" -ForegroundColor Cyan
Write-Host ""

while ($true) {
    Clear-Host
    Write-Host "=== Статус скачивания ===" -ForegroundColor Cyan
    Write-Host "Время: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
    
    if (Test-Path $TEMP_FILE) {
        $file = Get-Item $TEMP_FILE
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        $progress = [math]::Round(($sizeMB / 800) * 100, 1)
        $lastWrite = $file.LastWriteTime
        
        Write-Host "✅ Файл скачивается!" -ForegroundColor Green
        Write-Host "Скачано: $sizeMB MB из ~800 MB" -ForegroundColor Cyan
        Write-Host "Прогресс: $progress%" -ForegroundColor Yellow
        Write-Host "Последнее обновление: $lastWrite" -ForegroundColor Gray
        
        # Проверяем, не застряло ли скачивание (не обновлялось более 2 минут)
        $timeSinceUpdate = (Get-Date) - $lastWrite
        if ($timeSinceUpdate.TotalMinutes -gt 2) {
            Write-Host ""
            Write-Host "⚠️ ВНИМАНИЕ: Файл не обновлялся более 2 минут!" -ForegroundColor Yellow
            Write-Host "Скачивание может быть прервано." -ForegroundColor Yellow
        }
    } else {
        Write-Host "⏳ Ожидание начала скачивания..." -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    if (Test-Path $FINAL_FILE) {
        $file = Get-Item $FINAL_FILE
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        Write-Host "✅ МОДЕЛЬ ГОТОВА!" -ForegroundColor Green
        Write-Host "Файл: $FINAL_FILE" -ForegroundColor White
        Write-Host "Размер: $sizeMB MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🎉 Модель успешно скачана и сжата!" -ForegroundColor Green
        break
    }
    
    Write-Host "Обновление через 30 секунд... (Ctrl+C для выхода)" -ForegroundColor Gray
    Start-Sleep -Seconds 30
}
