# Исправленный скрипт для сжатия модели с правильными параметрами

$ErrorActionPreference = "Continue"

Write-Host "=== Compressing model with proper xz settings ===" -ForegroundColor Green

$MODEL_DIR = "assets\aka\models"
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR "model_v1_temp.gguf"
$MODEL_PATH = Join-Path $MODEL_DIR "model_v1.bin.xz"

# Проверяем наличие скачанного файла
if (-not (Test-Path $TEMP_MODEL_PATH)) {
    Write-Host "❌ ERROR: Downloaded file not found: $TEMP_MODEL_PATH" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $TEMP_MODEL_PATH).Length
$fileSizeMB = [math]::Round($fileSize / 1MB, 2)
Write-Host "Found downloaded file: $fileSizeMB MB" -ForegroundColor Cyan

# Удаляем старый неэффективно сжатый файл если есть
if (Test-Path $MODEL_PATH) {
    $oldSize = (Get-Item $MODEL_PATH).Length
    $oldSizeMB = [math]::Round($oldSize / 1MB, 2)
    $ratio = [math]::Round(($oldSize / $fileSize) * 100, 1)
    
    if ($ratio -gt 50) {
        Write-Host "⚠️ Old compressed file is too large ($oldSizeMB MB, $ratio% of original)" -ForegroundColor Yellow
        Write-Host "Removing old file and recompressing..." -ForegroundColor Yellow
        Remove-Item $MODEL_PATH -Force -ErrorAction SilentlyContinue
    }
}

# Проверяем наличие xz или 7-Zip
$xzAvailable = $false
$xzPath = $null
$7zPath = $null

# Список возможных путей к xz.exe
$xzPaths = @(
    "xz",  # В PATH
    "$env:USERPROFILE\Downloads\xz-5.8.2-windows\bin_x86-64\xz.exe",
    "C:\Program Files\xz\bin\xz.exe"
)

# Пробуем найти xz
foreach ($path in $xzPaths) {
    if ($path -eq "xz") {
        try {
            $xzCmd = Get-Command xz -ErrorAction Stop
            $xzAvailable = $true
            $xzPath = $xzCmd.Source
            Write-Host "✅ Found xz utility in PATH: $xzPath" -ForegroundColor Green
            break
        } catch {
            continue
        }
    } elseif (Test-Path $path) {
        $xzAvailable = $true
        $xzPath = $path
        Write-Host "✅ Found xz utility: $xzPath" -ForegroundColor Green
        break
    }
}

# Если xz не найден, проверяем 7-Zip
if (-not $xzAvailable) {
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
    Write-Host "Please install xz: https://tukaani.org/xz/" -ForegroundColor Cyan
    exit 1
}

# Сжимаем модель
Write-Host ""
Write-Host "Compressing model (this may take 10-20 minutes)..." -ForegroundColor Cyan
Write-Host "Using maximum compression level for best results..." -ForegroundColor Yellow

$startTime = Get-Date

if ($xzAvailable) {
    Write-Host "Using xz with maximum compression (-9)..." -ForegroundColor Cyan
    # xz с максимальным уровнем сжатия
    if ($xzPath -like "* *") {
        $process = Start-Process -FilePath "`"$xzPath`"" -ArgumentList @("-z", "-k", "-9", $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    } else {
        $process = Start-Process -FilePath $xzPath -ArgumentList @("-z", "-k", "-9", $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    }
    if ($process.ExitCode -ne 0) {
        Write-Host "❌ xz compression failed with exit code $($process.ExitCode)" -ForegroundColor Red
        exit 1
    }
    
    $compressedTempPath = "$TEMP_MODEL_PATH.xz"
    if (Test-Path $compressedTempPath) {
        Move-Item -Path $compressedTempPath -Destination $MODEL_PATH -Force
        Write-Host "✅ Compression complete!" -ForegroundColor Green
    } else {
        Write-Host "❌ Compressed file not found" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Using 7-Zip with maximum compression (-mx=9)..." -ForegroundColor Cyan
    # 7-Zip с максимальным уровнем сжатия и правильным форматом
    $process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-txz", "-mx=9", "-mmt=on", $MODEL_PATH, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) {
        Write-Host "❌ 7-Zip compression failed with exit code $($process.ExitCode)" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Compression complete!" -ForegroundColor Green
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Progress -Activity "Compressing" -Completed

# Проверяем результат сжатия
$compressedSize = (Get-Item $MODEL_PATH).Length
$compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
$compressionRatio = [math]::Round(($compressedSize / $fileSize) * 100, 1)

Write-Host ""
Write-Host "=== Compression Results ===" -ForegroundColor Cyan
Write-Host "Original size: $fileSizeMB MB" -ForegroundColor White
Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
Write-Host "Compression ratio: $compressionRatio%" -ForegroundColor White
Write-Host "Compression time: $([math]::Round($duration.TotalMinutes,1)) minutes" -ForegroundColor White
Write-Host ""

if ($compressionRatio -gt 50) {
    Write-Host "⚠️ WARNING: Compression ratio is high ($compressionRatio%)" -ForegroundColor Yellow
    Write-Host "Expected ratio should be ~20-30% for GGUF models" -ForegroundColor Yellow
    Write-Host "The file might not be properly compressed." -ForegroundColor Yellow
} else {
    Write-Host "✅ Compression is effective!" -ForegroundColor Green
}

# Удаляем временный несжатый файл только если сжатие эффективно
if ($compressionRatio -lt 50) {
    Write-Host "Removing temporary file..." -ForegroundColor Cyan
    Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "=== ✅ SUCCESS ===" -ForegroundColor Green
    Write-Host "Compressed model: $MODEL_PATH" -ForegroundColor White
    Write-Host "Size: $compressedSizeMB MB" -ForegroundColor White
    Write-Host ""
    Write-Host "🎉 Model is ready to use in the app!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️ Keeping original file for manual compression" -ForegroundColor Yellow
    Write-Host "You may need to use native xz utility for better compression" -ForegroundColor Yellow
}
