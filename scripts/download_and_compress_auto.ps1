# Автоматический скрипт: скачивание и сжатие модели Q3_K_S

$ErrorActionPreference = "Continue"

Write-Host "=== Автоматическое скачивание и сжатие Q3_K_S ===" -ForegroundColor Green
Write-Host ""

$MODEL_DIR = "assets\aka\models"
$TEMP_FILE = Join-Path $MODEL_DIR "model_v1_temp.gguf"
$MODEL_FILE = Join-Path $MODEL_DIR "model_v1.bin.xz"
$URL = "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q3_K_S.gguf"

# Проверяем, не скачана ли уже модель
if (Test-Path $MODEL_FILE) {
    $size = (Get-Item $MODEL_FILE).Length
    $sizeMB = [math]::Round($size/1MB,2)
    if ($sizeMB -lt 500) {
        Write-Host "✅ Модель уже готова: $sizeMB MB" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "⚠️ Найден файл большого размера ($sizeMB MB), пересжимаю..." -ForegroundColor Yellow
        Remove-Item $MODEL_FILE -Force -ErrorAction SilentlyContinue
    }
}

# Скачиваем модель
Write-Host "Скачивание модели Q3_K_S (~1.1 GB)..." -ForegroundColor Cyan
Write-Host "Это может занять 15-40 минут..." -ForegroundColor Yellow
Write-Host ""

try {
    $ProgressPreference = 'Continue'
    Invoke-WebRequest -Uri $URL -OutFile $TEMP_FILE -UseBasicParsing -ErrorAction Stop
    
    $fileSize = (Get-Item $TEMP_FILE).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host ""
    Write-Host "✅ Скачивание завершено: $fileSizeMB MB" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка скачивания: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Сжимаем модель
Write-Host ""
Write-Host "Сжатие модели с максимальным уровнем..." -ForegroundColor Cyan
Write-Host "Это может занять 5-15 минут..." -ForegroundColor Yellow
Write-Host ""

$7zPath = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path $7zPath)) {
    $7zPath = "C:\Program Files (x86)\7-Zip\7z.exe"
}

if (-not (Test-Path $7zPath)) {
    Write-Host "❌ 7-Zip не найден!" -ForegroundColor Red
    Write-Host "Скачанный файл сохранен: $TEMP_FILE" -ForegroundColor Yellow
    exit 1
}

$startTime = Get-Date

# Сжимаем с максимальным уровнем
Write-Host "Используется: $7zPath" -ForegroundColor Gray
Write-Host "Параметры: -txz -mx=9 -mmt=on (максимальное сжатие)" -ForegroundColor Gray
Write-Host ""

$process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-txz", "-mx=9", "-mmt=on", $MODEL_FILE, $TEMP_FILE) -Wait -PassThru -NoNewWindow

if ($process.ExitCode -ne 0) {
    Write-Host "❌ Ошибка сжатия (код: $($process.ExitCode))" -ForegroundColor Red
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Проверяем результат
$compressedSize = (Get-Item $MODEL_FILE).Length
$compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
$compressionRatio = [math]::Round(($compressedSize / $fileSize) * 100, 1)

Write-Host ""
Write-Host "=== Результаты сжатия ===" -ForegroundColor Cyan
Write-Host "Исходный размер: $fileSizeMB MB" -ForegroundColor White
Write-Host "Сжатый размер: $compressedSizeMB MB" -ForegroundColor White
Write-Host "Коэффициент сжатия: $compressionRatio%" -ForegroundColor White
Write-Host "Время сжатия: $([math]::Round($duration.TotalMinutes,1)) минут" -ForegroundColor White
Write-Host ""

if ($compressionRatio -lt 50) {
    Write-Host "✅ Сжатие эффективно!" -ForegroundColor Green
    Write-Host "Удаляю временный файл..." -ForegroundColor Cyan
    Remove-Item $TEMP_FILE -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "=== ✅ УСПЕХ ===" -ForegroundColor Green
    Write-Host "Модель готова: $MODEL_FILE" -ForegroundColor White
    Write-Host "Размер: $compressedSizeMB MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 Модель готова к использованию!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Коэффициент сжатия высокий ($compressionRatio%)" -ForegroundColor Yellow
    Write-Host "Ожидалось: ~20-30%" -ForegroundColor Yellow
    Write-Host "Временный файл сохранен для проверки" -ForegroundColor Yellow
}
