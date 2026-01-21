# Быстрый скрипт для скачивания Q3_K_S модели

$ErrorActionPreference = "Continue"

Write-Host "=== Downloading Llama 3.2 3B Q3_K_S model ===" -ForegroundColor Green
Write-Host "This model is a good compromise: ~1.1GB (vs ~1.5GB for Q4_K_S)" -ForegroundColor Cyan
Write-Host "After compression: ~350MB (vs ~450MB)" -ForegroundColor Cyan
Write-Host ""

$MODEL_DIR = "assets\aka\models"
$MODEL_NAME = "model_v1.bin.xz"
$TEMP_MODEL_NAME = "model_v1_temp.gguf"
$MODEL_URL = "https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q3_K_S.gguf"

$MODEL_PATH = Join-Path $MODEL_DIR $MODEL_NAME
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR $TEMP_MODEL_NAME

# Создаем директорию
if (-not (Test-Path $MODEL_DIR)) {
    New-Item -ItemType Directory -Path $MODEL_DIR -Force | Out-Null
}

# Удаляем старые файлы
if (Test-Path $MODEL_PATH) {
    $oldSize = (Get-Item $MODEL_PATH).Length
    $oldSizeMB = [math]::Round($oldSize / 1MB, 2)
    Write-Host "Removing old model file ($oldSizeMB MB)..." -ForegroundColor Yellow
    Remove-Item $MODEL_PATH -Force -ErrorAction SilentlyContinue
}

if (Test-Path $TEMP_MODEL_PATH) {
    $tempSize = (Get-Item $TEMP_MODEL_PATH).Length
    $tempSizeMB = [math]::Round($tempSize / 1MB, 2)
        if ($tempSizeMB -gt 1500 -or $tempSizeMB -lt 800) {
            Write-Host "Removing old file ($tempSizeMB MB)..." -ForegroundColor Yellow
            Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue
        }
}

# Проверяем, существует ли уже сжатая модель
if (Test-Path $MODEL_PATH) {
    $fileSize = (Get-Item $MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    if ($fileSizeMB -lt 400) {
        Write-Host "✅ Compressed model already exists: $MODEL_PATH" -ForegroundColor Green
        Write-Host "   Size: $fileSizeMB MB" -ForegroundColor Cyan
        Write-Host "   Model is ready to use!" -ForegroundColor Green
        exit 0
    }
}

Write-Host "Starting download..." -ForegroundColor Cyan
Write-Host "URL: $MODEL_URL" -ForegroundColor Gray
Write-Host "Expected size: ~800 MB" -ForegroundColor Yellow
Write-Host ""

try {
    $ProgressPreference = 'Continue'
    
    Write-Host "Downloading Q3_K_S model (good quality/size balance)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $MODEL_URL -OutFile $TEMP_MODEL_PATH -UseBasicParsing
    
    $fileSize = (Get-Item $TEMP_MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
    
    Write-Host ""
    Write-Host "✅ Download complete: $fileSizeMB MB ($fileSizeGB GB)" -ForegroundColor Green
    
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
        Write-Host "Please install 7-Zip: https://www.7-zip.org/" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "The downloaded file is saved at: $TEMP_MODEL_PATH" -ForegroundColor Yellow
        Write-Host "You can compress it manually later." -ForegroundColor Yellow
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
    
} catch {
    Write-Host ""
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    if (Test-Path $TEMP_MODEL_PATH) {
        $currentSize = (Get-Item $TEMP_MODEL_PATH).Length
        $currentMB = [math]::Round($currentSize / 1MB, 2)
        Write-Host "Partial download saved: $TEMP_MODEL_PATH ($currentMB MB)" -ForegroundColor Yellow
        Write-Host "You can resume by running this script again." -ForegroundColor Yellow
    }
    
    exit 1
}
