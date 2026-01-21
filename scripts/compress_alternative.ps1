# Альтернативные методы сжатия для GGUF файлов
# Пробует разные форматы и выбирает лучший

$ErrorActionPreference = "Continue"

Write-Host "=== Alternative Compression Methods ===" -ForegroundColor Green
Write-Host ""

$MODEL_DIR = "assets\aka\models"
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR "model_v1_temp.gguf"
$MODEL_PATH = Join-Path $MODEL_DIR "model_v1.bin.xz"

if (-not (Test-Path $TEMP_MODEL_PATH)) {
    Write-Host "❌ ERROR: Source file not found: $TEMP_MODEL_PATH" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $TEMP_MODEL_PATH).Length
$fileSizeMB = [math]::Round($fileSize / 1MB, 2)
Write-Host "Source file: $fileSizeMB MB" -ForegroundColor Cyan
Write-Host ""

# Проверяем доступные утилиты
$7zPath = $null
$7zPaths = @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe"
)

foreach ($path in $7zPaths) {
    if (Test-Path $path) {
        $7zPath = $path
        break
    }
}

if (-not $7zPath) {
    Write-Host "❌ 7-Zip not found" -ForegroundColor Red
    exit 1
}

Write-Host "Testing different compression methods..." -ForegroundColor Cyan
Write-Host ""

$results = @()

# Метод 1: xz с максимальным сжатием
Write-Host "1. Testing xz format (maximum compression)..." -ForegroundColor Yellow
$xzPath = Join-Path $MODEL_DIR "test_xz.xz"
if (Test-Path $xzPath) { Remove-Item $xzPath -Force }

$process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-txz", "-mx=9", "-mmt=on", "-mm=LZMA2", $xzPath, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0 -and (Test-Path $xzPath)) {
    $xzSize = (Get-Item $xzPath).Length
    $xzSizeMB = [math]::Round($xzSize / 1MB, 2)
    $xzRatio = [math]::Round(($xzSize / $fileSize) * 100, 1)
    $results += [PSCustomObject]@{
        Method = "xz (LZMA2)"
        SizeMB = $xzSizeMB
        Ratio = $xzRatio
        Path = $xzPath
    }
    Write-Host "   Result: $xzSizeMB MB ($xzRatio%)" -ForegroundColor $(if ($xzRatio -lt 50) { "Green" } else { "Yellow" })
} else {
    Write-Host "   Failed" -ForegroundColor Red
}

# Метод 2: 7z с максимальным сжатием
Write-Host "2. Testing 7z format (maximum compression)..." -ForegroundColor Yellow
$7zPath_test = Join-Path $MODEL_DIR "test_7z.7z"
if (Test-Path $7zPath_test) { Remove-Item $7zPath_test -Force }

$process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-t7z", "-mx=9", "-mmt=on", "-mm=LZMA2", $7zPath_test, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0 -and (Test-Path $7zPath_test)) {
    $7zSize = (Get-Item $7zPath_test).Length
    $7zSizeMB = [math]::Round($7zSize / 1MB, 2)
    $7zRatio = [math]::Round(($7zSize / $fileSize) * 100, 1)
    $results += [PSCustomObject]@{
        Method = "7z (LZMA2)"
        SizeMB = $7zSizeMB
        Ratio = $7zRatio
        Path = $7zPath_test
    }
    Write-Host "   Result: $7zSizeMB MB ($7zRatio%)" -ForegroundColor $(if ($7zRatio -lt 50) { "Green" } else { "Yellow" })
} else {
    Write-Host "   Failed" -ForegroundColor Red
}

# Метод 3: zip с максимальным сжатием
Write-Host "3. Testing zip format (maximum compression)..." -ForegroundColor Yellow
$zipPath = Join-Path $MODEL_DIR "test_zip.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

$process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-tzip", "-mx=9", "-mmt=on", "-mm=Deflate", $zipPath, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0 -and (Test-Path $zipPath)) {
    $zipSize = (Get-Item $zipPath).Length
    $zipSizeMB = [math]::Round($zipSize / 1MB, 2)
    $zipRatio = [math]::Round(($zipSize / $fileSize) * 100, 1)
    $results += [PSCustomObject]@{
        Method = "zip (Deflate)"
        SizeMB = $zipSizeMB
        Ratio = $zipRatio
        Path = $zipPath
    }
    Write-Host "   Result: $zipSizeMB MB ($zipRatio%)" -ForegroundColor $(if ($zipRatio -lt 50) { "Green" } else { "Yellow" })
} else {
    Write-Host "   Failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Compression Results ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Выбираем лучший результат
$best = $results | Where-Object { $_.Ratio -lt 50 } | Sort-Object Ratio | Select-Object -First 1

if ($best) {
    Write-Host ""
    Write-Host "✅ Best compression: $($best.Method)" -ForegroundColor Green
    Write-Host "   Size: $($best.SizeMB) MB" -ForegroundColor Cyan
    Write-Host "   Ratio: $($best.Ratio)%" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Moving best result to final location..." -ForegroundColor Yellow
    
    # Удаляем старый файл
    if (Test-Path $MODEL_PATH) {
        Remove-Item $MODEL_PATH -Force -ErrorAction SilentlyContinue
    }
    
    # Переименовываем в зависимости от формата
    if ($best.Method -like "*xz*") {
        Move-Item -Path $best.Path -Destination $MODEL_PATH -Force
    } else {
        # Для других форматов нужно обновить ModelVersionManager
        Write-Host "⚠️ Best format is not xz, need to update ModelVersionManager" -ForegroundColor Yellow
        Write-Host "Keeping xz format for compatibility" -ForegroundColor Yellow
        if (Test-Path $xzPath) {
            Move-Item -Path $xzPath -Destination $MODEL_PATH -Force
        }
    }
    
    # Удаляем тестовые файлы
    $results | ForEach-Object {
        if ($_.Path -ne $best.Path -and (Test-Path $_.Path)) {
            Remove-Item $_.Path -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host ""
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Final file: $MODEL_PATH" -ForegroundColor White
    Write-Host "Size: $($best.SizeMB) MB" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ No effective compression found!" -ForegroundColor Red
    Write-Host "All methods resulted in >50% ratio" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "1. GGUF file is already compressed" -ForegroundColor Gray
    Write-Host "2. Binary model data has low entropy" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Recommendation: Use uncompressed file or install native xz" -ForegroundColor Cyan
    
    # Удаляем тестовые файлы
    $results | ForEach-Object {
        if (Test-Path $_.Path) {
            Remove-Item $_.Path -Force -ErrorAction SilentlyContinue
        }
    }
    
    exit 1
}
