# Упрощенный скрипт для скачивания и сжатия модели
# Запускается без интерактивных запросов

$ErrorActionPreference = "Stop"

Write-Host "=== Downloading and compressing Llama 3.2 3B Q3_K_S model ===" -ForegroundColor Green

$MODEL_DIR = "assets\aka\models"
$MODEL_NAME = "model_v1.bin.xz"
$TEMP_MODEL_NAME = "model_v1_temp.gguf"
$MODEL_URL = "https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q3_K_S.gguf"

$MODEL_PATH = Join-Path $MODEL_DIR $MODEL_NAME
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR $TEMP_MODEL_NAME

# Создаем директорию если не существует
if (-not (Test-Path $MODEL_DIR)) {
    New-Item -ItemType Directory -Path $MODEL_DIR -Force | Out-Null
}

# Удаляем старые временные файлы
if (Test-Path $TEMP_MODEL_PATH) {
    Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue
    Write-Host "Removed old temporary file" -ForegroundColor Yellow
}

# Проверяем, существует ли уже сжатая модель
if (Test-Path $MODEL_PATH) {
    $fileSize = (Get-Item $MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "Compressed model already exists: $MODEL_PATH" -ForegroundColor Green
    Write-Host "File size: $fileSizeMB MB" -ForegroundColor Cyan
    Write-Host "Model is ready to use!" -ForegroundColor Green
    exit 0
}

Write-Host "Starting download..." -ForegroundColor Cyan
Write-Host "URL: $MODEL_URL" -ForegroundColor Gray
Write-Host "This will download ~1.1GB and compress to ~350MB" -ForegroundColor Yellow
Write-Host ""

try {
    $ProgressPreference = 'Continue'
    
    # Скачиваем модель
    Write-Host "Downloading model (this may take 10-30 minutes)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $MODEL_URL -OutFile $TEMP_MODEL_PATH -UseBasicParsing
    
    $fileSize = (Get-Item $TEMP_MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
    
    Write-Host ""
    Write-Host "Download complete: $fileSizeMB MB ($fileSizeGB GB)" -ForegroundColor Green
    
    # Проверяем наличие xz или 7-Zip
    $xzAvailable = $false
    $7zPath = $null
    
    # Проверяем xz
    try {
        $null = Get-Command xz -ErrorAction Stop
        $xzAvailable = $true
    } catch {
        # Проверяем 7-Zip
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
    }
    
    if (-not $xzAvailable -and -not $7zPath) {
        Write-Host ""
        Write-Host "ERROR: xz or 7-Zip not found!" -ForegroundColor Red
        Write-Host "Please install one of:" -ForegroundColor Yellow
        Write-Host "1. xz for Windows: https://tukaani.org/xz/" -ForegroundColor Cyan
        Write-Host "2. 7-Zip: https://www.7-zip.org/" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or compress manually:" -ForegroundColor Yellow
        Write-Host "  xz -z -k $TEMP_MODEL_PATH" -ForegroundColor Gray
        Write-Host "  Then rename to: $MODEL_PATH" -ForegroundColor Gray
        exit 1
    }
    
    # Сжимаем модель используя умный скрипт
    Write-Host ""
    Write-Host "Compressing model with smart compression script..." -ForegroundColor Cyan
    Write-Host "This will check compression effectiveness before removing original file" -ForegroundColor Yellow
    
    $compressScript = Join-Path $PSScriptRoot "compress_model_smart.ps1"
    if (Test-Path $compressScript) {
        & $compressScript
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "⚠️ Compression was not effective" -ForegroundColor Yellow
            Write-Host "Original file is kept at: $TEMP_MODEL_PATH" -ForegroundColor Yellow
            Write-Host "You can use the uncompressed file or try manual compression" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "Smart compression script not found, using basic method..." -ForegroundColor Yellow
        & "$PSScriptRoot\compress_model_fixed.ps1"
    }
    
    # Проверяем результат
    if (Test-Path $MODEL_PATH) {
        $compressedSize = (Get-Item $MODEL_PATH).Length
        $compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
        
        Write-Host ""
        Write-Host "=== SUCCESS ===" -ForegroundColor Green
        Write-Host "Compressed model: $MODEL_PATH" -ForegroundColor White
        Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
        Write-Host ""
        Write-Host "Model is ready to use in the app!" -ForegroundColor Green
    }
    
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can:" -ForegroundColor Yellow
    Write-Host "1. Try running the script again" -ForegroundColor Cyan
    Write-Host "2. Download manually from: $MODEL_URL" -ForegroundColor Cyan
    Write-Host "3. Compress with: xz -z -k <downloaded_file>" -ForegroundColor Cyan
    Write-Host "4. Rename to: $MODEL_PATH" -ForegroundColor Cyan
    exit 1
}
