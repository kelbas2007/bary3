# Умный скрипт для сжатия модели
# НЕ удаляет исходный файл до проверки эффективности сжатия

$ErrorActionPreference = "Continue"

Write-Host "=== Smart Model Compression ===" -ForegroundColor Green
Write-Host ""

$MODEL_DIR = "assets\aka\models"
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR "model_v1_temp.gguf"
$MODEL_PATH = Join-Path $MODEL_DIR "model_v1.bin.xz"
$TEST_COMPRESSED_PATH = Join-Path $MODEL_DIR "model_v1_test.xz"

# Проверяем наличие скачанного файла
if (-not (Test-Path $TEMP_MODEL_PATH)) {
    Write-Host "❌ ERROR: Downloaded file not found: $TEMP_MODEL_PATH" -ForegroundColor Red
    Write-Host "Please download the model first using download_model_resumable.ps1" -ForegroundColor Yellow
    exit 1
}

$fileSize = (Get-Item $TEMP_MODEL_PATH).Length
$fileSizeMB = [math]::Round($fileSize / 1MB, 2)
Write-Host "Found downloaded file: $fileSizeMB MB" -ForegroundColor Cyan
Write-Host ""

# Проверяем наличие нативного xz (предпочтительно)
$xzAvailable = $false
$xzPath = $null
$7zPath = $null

# Список возможных путей к xz.exe
$xzPaths = @(
    # В PATH
    "xz",
    # Стандартные места установки
    "C:\Program Files\xz\bin\xz.exe",
    "C:\Program Files (x86)\xz\bin\xz.exe",
    # Загрузки пользователя
    "$env:USERPROFILE\Downloads\xz-5.8.2-windows\bin_x86-64\xz.exe",
    "$env:USERPROFILE\Downloads\xz-*\bin_x86-64\xz.exe",
    # Другие возможные места
    "$env:LOCALAPPDATA\xz\bin\xz.exe"
)

# Сначала пробуем найти в PATH
try {
    $xzCmd = Get-Command xz -ErrorAction Stop
    $xzAvailable = $true
    $xzPath = $xzCmd.Source
    Write-Host "✅ Found native xz in PATH: $xzPath" -ForegroundColor Green
} catch {
    # Ищем в стандартных местах
    foreach ($path in $xzPaths) {
        # Обрабатываем wildcard пути
        if ($path -like "*`**") {
            $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
            if ($resolved) {
                $path = $resolved[0].Path
            }
        }
        
        if ($path -ne "xz" -and (Test-Path $path)) {
            $xzAvailable = $true
            $xzPath = $path
            Write-Host "✅ Found native xz: $xzPath" -ForegroundColor Green
            break
        }
    }
    
    if (-not $xzAvailable) {
        Write-Host "⚠️ Native xz not found in PATH or standard locations" -ForegroundColor Yellow
        
        # Проверяем 7-Zip как fallback
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
}

if (-not $xzAvailable -and -not $7zPath) {
    Write-Host ""
    Write-Host "❌ ERROR: xz or 7-Zip not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install one of:" -ForegroundColor Yellow
    Write-Host "1. xz for Windows: https://tukaani.org/xz/" -ForegroundColor Cyan
    Write-Host "   (Recommended for best compression)" -ForegroundColor Gray
    Write-Host "2. 7-Zip: https://www.7-zip.org/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "The original file is kept at: $TEMP_MODEL_PATH" -ForegroundColor Yellow
    exit 1
}

# Сжимаем во временный файл для проверки
Write-Host ""
Write-Host "Compressing model (this may take 10-20 minutes)..." -ForegroundColor Cyan
Write-Host "Using maximum compression level..." -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
$compressionSuccess = $false

if ($xzAvailable) {
    Write-Host "Using native xz with maximum compression (-9 -e)..." -ForegroundColor Cyan
    Write-Host "Command: $xzPath -z -k -9 -e $TEMP_MODEL_PATH" -ForegroundColor Gray
    
    # Используем -e для лучшего сжатия (extreme)
    # Если путь содержит пробелы, используем кавычки
    if ($xzPath -like "* *") {
        $process = Start-Process -FilePath "`"$xzPath`"" -ArgumentList @("-z", "-k", "-9", "-e", $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    } else {
        $process = Start-Process -FilePath $xzPath -ArgumentList @("-z", "-k", "-9", "-e", $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    }
    
    if ($process.ExitCode -eq 0) {
        $compressedTempPath = "$TEMP_MODEL_PATH.xz"
        if (Test-Path $compressedTempPath) {
            $compressionSuccess = $true
            $TEST_COMPRESSED_PATH = $compressedTempPath
            Write-Host "✅ Compression complete!" -ForegroundColor Green
        } else {
            Write-Host "❌ Compressed file not found" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ xz compression failed with exit code $($process.ExitCode)" -ForegroundColor Red
    }
} else {
    Write-Host "Using 7-Zip with maximum compression..." -ForegroundColor Cyan
    Write-Host "Note: 7-Zip may not compress GGUF files effectively" -ForegroundColor Yellow
    Write-Host "Command: 7z a -txz -mx=9 -mmt=on $TEST_COMPRESSED_PATH $TEMP_MODEL_PATH" -ForegroundColor Gray
    
    # Сжимаем во временный файл для проверки
    $process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-txz", "-mx=9", "-mmt=on", "-mm=LZMA2", $TEST_COMPRESSED_PATH, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        if (Test-Path $TEST_COMPRESSED_PATH) {
            $compressionSuccess = $true
            Write-Host "✅ Compression complete!" -ForegroundColor Green
        } else {
            Write-Host "❌ Compressed file not found" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ 7-Zip compression failed with exit code $($process.ExitCode)" -ForegroundColor Red
    }
}

if (-not $compressionSuccess) {
    Write-Host ""
    Write-Host "❌ Compression failed!" -ForegroundColor Red
    Write-Host "Original file is kept at: $TEMP_MODEL_PATH" -ForegroundColor Yellow
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Проверяем результат сжатия
$compressedSize = (Get-Item $TEST_COMPRESSED_PATH).Length
$compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
$compressionRatio = [math]::Round(($compressedSize / $fileSize) * 100, 1)

Write-Host ""
Write-Host "=== Compression Results ===" -ForegroundColor Cyan
Write-Host "Original size: $fileSizeMB MB" -ForegroundColor White
Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
Write-Host "Compression ratio: $compressionRatio%" -ForegroundColor White
Write-Host "Compression time: $([math]::Round($duration.TotalMinutes,1)) minutes" -ForegroundColor White
Write-Host ""

# Проверяем эффективность сжатия
if ($compressionRatio -gt 50) {
    Write-Host "❌ WARNING: Compression is NOT effective!" -ForegroundColor Red
    Write-Host "Compression ratio: $compressionRatio% (expected: 20-30%)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "1. GGUF file is already compressed" -ForegroundColor Gray
    Write-Host "2. 7-Zip may not handle xz format correctly for GGUF files" -ForegroundColor Gray
    Write-Host "3. Need native xz utility for better compression" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Removing test compressed file..." -ForegroundColor Yellow
    Remove-Item $TEST_COMPRESSED_PATH -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "⚠️ Original file is kept: $TEMP_MODEL_PATH" -ForegroundColor Yellow
    Write-Host "Recommendation: Install native xz utility for better compression" -ForegroundColor Cyan
    Write-Host "Or: Use the uncompressed file (larger APK size)" -ForegroundColor Yellow
    exit 1
}

# Сжатие эффективно - перемещаем файл и удаляем исходный
Write-Host "✅ Compression is effective!" -ForegroundColor Green
Write-Host ""

# Удаляем старый неэффективно сжатый файл если есть
if (Test-Path $MODEL_PATH) {
    $oldSize = (Get-Item $MODEL_PATH).Length
    $oldSizeMB = [math]::Round($oldSize / 1MB, 2)
    Write-Host "Removing old compressed file ($oldSizeMB MB)..." -ForegroundColor Yellow
    Remove-Item $MODEL_PATH -Force -ErrorAction SilentlyContinue
}

# Перемещаем сжатый файл на место
if ($xzAvailable) {
    # xz создает файл рядом с исходным
    Move-Item -Path $TEST_COMPRESSED_PATH -Destination $MODEL_PATH -Force
} else {
    # 7-Zip создает архив с указанным именем
    Move-Item -Path $TEST_COMPRESSED_PATH -Destination $MODEL_PATH -Force
}

Write-Host "Removing temporary uncompressed file..." -ForegroundColor Cyan
Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== ✅ SUCCESS ===" -ForegroundColor Green
Write-Host "Compressed model: $MODEL_PATH" -ForegroundColor White
Write-Host "Original size: $fileSizeMB MB" -ForegroundColor White
Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
Write-Host "Compression ratio: $compressionRatio%" -ForegroundColor White
Write-Host "Size reduction: $([math]::Round((1 - $compressedSize/$fileSize)*100,1))%" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 Model is ready to use in the app!" -ForegroundColor Green
