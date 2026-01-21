# Скрипт для сжатия уже скачанной модели

$ErrorActionPreference = "Continue"

Write-Host "=== Compressing downloaded model ===" -ForegroundColor Green

$MODEL_DIR = "assets\aka\models"
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR "model_v1_temp.gguf"
$MODEL_PATH = Join-Path $MODEL_DIR "model_v1.bin.xz"

# Проверяем наличие скачанного файла
if (-not (Test-Path $TEMP_MODEL_PATH)) {
    Write-Host "❌ ERROR: Downloaded file not found: $TEMP_MODEL_PATH" -ForegroundColor Red
    Write-Host "Please download the model first using download_model_resumable.ps1" -ForegroundColor Yellow
    exit 1
}

$fileSize = (Get-Item $TEMP_MODEL_PATH).Length
$fileSizeMB = [math]::Round($fileSize / 1MB, 2)
Write-Host "Found downloaded file: $fileSizeMB MB" -ForegroundColor Cyan

# Проверяем наличие xz или 7-Zip
$xzAvailable = $false
$7zPath = $null

try {
    $null = Get-Command xz -ErrorAction Stop
    $xzAvailable = $true
    Write-Host "✅ Found xz utility" -ForegroundColor Green
} catch {
    $7zPaths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe"
    )
    
    foreach ($path in $7zPaths) {
        if (Test-Path $path) {
            $7zPath = $path
            Write-Host "✅ Found 7-Zip: $path" -ForegroundColor Green
            break
        }
    }
}

if (-not $xzAvailable -and -not $7zPath) {
    Write-Host ""
    Write-Host "❌ ERROR: xz or 7-Zip not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install one of:" -ForegroundColor Yellow
    Write-Host "1. xz for Windows: https://tukaani.org/xz/" -ForegroundColor Cyan
    Write-Host "2. 7-Zip: https://www.7-zip.org/" -ForegroundColor Cyan
    exit 1
}

# Сжимаем модель
Write-Host ""
Write-Host "Compressing model with xz (this may take 5-15 minutes)..." -ForegroundColor Cyan
Write-Progress -Activity "Compressing" -Status "Starting compression..."

$startTime = Get-Date

if ($xzAvailable) {
    Write-Host "Using xz for compression..." -ForegroundColor Cyan
    $process = Start-Process -FilePath "xz" -ArgumentList @("-z", "-k", $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) {
        Write-Host "❌ xz compression failed with exit code $($process.ExitCode)" -ForegroundColor Red
        exit 1
    }
    
    $compressedTempPath = "$TEMP_MODEL_PATH.xz"
    if (Test-Path $compressedTempPath) {
        Move-Item -Path $compressedTempPath -Destination $MODEL_PATH -Force
        Write-Host "✅ Compression complete!" -ForegroundColor Green
    } else {
        Write-Host "❌ Compressed file not found: $compressedTempPath" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Using 7-Zip for compression..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-txz", $MODEL_PATH, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) {
        Write-Host "❌ 7-Zip compression failed with exit code $($process.ExitCode)" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Compression complete!" -ForegroundColor Green
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Progress -Activity "Compressing" -Completed

# Удаляем временный несжатый файл
Write-Host "Removing temporary file..." -ForegroundColor Cyan
Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue

# Проверяем результат
$compressedSize = (Get-Item $MODEL_PATH).Length
$compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
$compressionRatio = [math]::Round(($compressedSize / $fileSize) * 100, 1)

Write-Host ""
Write-Host "=== ✅ SUCCESS ===" -ForegroundColor Green
Write-Host "Compressed model: $MODEL_PATH" -ForegroundColor White
Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
Write-Host "Compression ratio: $compressionRatio%" -ForegroundColor White
Write-Host "Compression time: $([math]::Round($duration.TotalMinutes,1)) minutes" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Model is ready to use in the app!" -ForegroundColor Green
