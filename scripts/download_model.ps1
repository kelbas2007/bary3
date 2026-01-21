# Скрипт для скачивания модели Llama 3.2 3B Q4_K_S и сжатия xz (PowerShell для Windows)
# 
# Требования:
# - PowerShell 5.1+ или PowerShell Core
# - Достаточно места на диске (~1.5GB для скачивания, ~450MB после сжатия)
# - Утилита xz для сжатия (или 7-Zip)

param(
    [switch]$Force
)

Write-Host "=== Downloading Llama 3.2 3B Q3_K_S model and compressing with xz ===" -ForegroundColor Green

$MODEL_DIR = "assets\aka\models"
$MODEL_NAME = "model_v1.bin.xz"
$TEMP_MODEL_NAME = "model_v1_temp.gguf"
# Прямая ссылка на модель Q3_K_S (компромисс между качеством и размером)
# Альтернативные источники:
# 1. https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF
# 2. https://huggingface.co/QuantFactory/Llama-3.2-3B-Instruct-GGUF
$MODEL_URL = "https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q3_K_S.gguf"
$EXPECTED_SIZE = 1470000000 # ~1.47GB (несжатая)
$EXPECTED_COMPRESSED_SIZE = 350000000 # ~350MB (сжатая xz)

# Создаем директорию если не существует
if (-not (Test-Path $MODEL_DIR)) {
    New-Item -ItemType Directory -Path $MODEL_DIR -Force | Out-Null
    Write-Host "Created directory: $MODEL_DIR" -ForegroundColor Green
}

$MODEL_PATH = Join-Path $MODEL_DIR $MODEL_NAME
$TEMP_MODEL_PATH = Join-Path $MODEL_DIR $TEMP_MODEL_NAME

# Проверяем, существует ли уже сжатая модель
if ((Test-Path $MODEL_PATH) -and -not $Force) {
    $fileSize = (Get-Item $MODEL_PATH).Length
    Write-Host "Compressed model already exists: $MODEL_PATH" -ForegroundColor Yellow
    Write-Host "File size: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Cyan
    
    $response = Read-Host "Do you want to re-download and re-compress? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Skipping download" -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $MODEL_PATH -Force -ErrorAction SilentlyContinue
}

Write-Host "Downloading model from Hugging Face..." -ForegroundColor Cyan
Write-Host "URL: $MODEL_URL" -ForegroundColor Gray
Write-Host "Temporary file: $TEMP_MODEL_PATH" -ForegroundColor Gray
Write-Host "Final compressed file: $MODEL_PATH" -ForegroundColor Gray
Write-Host "Expected uncompressed size: ~1.1GB" -ForegroundColor Yellow
Write-Host "Expected compressed size: ~350MB" -ForegroundColor Yellow
Write-Host ""

# Проверяем доступное место на диске (нужно для несжатой + сжатой версии)
$drive = (Get-Item $MODEL_DIR).PSDrive
$freeSpace = $drive.Free
$requiredSpace = $EXPECTED_SIZE + $EXPECTED_COMPRESSED_SIZE
if ($freeSpace -lt $requiredSpace) {
    Write-Host "WARNING: Not enough free space on disk" -ForegroundColor Red
    Write-Host "Free space: $([math]::Round($freeSpace / 1GB, 2)) GB" -ForegroundColor Yellow
    Write-Host "Required: ~2 GB (for download + compression)" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# Используем Invoke-WebRequest для скачивания
Write-Host "Starting download (this may take a while)..." -ForegroundColor Cyan
Write-Host ""

try {
    $ProgressPreference = 'Continue'
    
    # Скачиваем несжатую модель с прогресс-баром
    Write-Host "Downloading uncompressed model..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $MODEL_URL -OutFile $TEMP_MODEL_PATH -UseBasicParsing
    
    # Проверяем размер скачанного файла
    $fileSize = (Get-Item $TEMP_MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
    
    Write-Host ""
    Write-Host "=== Download complete ===" -ForegroundColor Green
    Write-Host "Uncompressed model: $TEMP_MODEL_PATH" -ForegroundColor White
    Write-Host "File size: $fileSizeMB MB ($fileSizeGB GB)" -ForegroundColor White
    
    if ($fileSize -lt ($EXPECTED_SIZE * 0.9)) {
        Write-Host ""
        Write-Host "WARNING: File size is less than expected" -ForegroundColor Yellow
        Write-Host "The download might be incomplete. Please check the file." -ForegroundColor Yellow
    }
    
    # Сжимаем модель с помощью xz
    Write-Host ""
    Write-Host "Compressing model with xz..." -ForegroundColor Cyan
    
    # Проверяем наличие xz
    $xzAvailable = $false
    try {
        $null = Get-Command xz -ErrorAction Stop
        $xzAvailable = $true
    } catch {
        Write-Host "xz utility not found in PATH" -ForegroundColor Yellow
    }
    
    if (-not $xzAvailable) {
        # Пробуем найти xz в стандартных местах или использовать 7-Zip
        $xzPaths = @(
            "C:\Program Files\7-Zip\7z.exe",
            "C:\Program Files (x86)\7-Zip\7z.exe",
            "$env:ProgramFiles\7-Zip\7z.exe",
            "$env:ProgramFiles(x86)\7-Zip\7z.exe"
        )
        
        $7zPath = $null
        foreach ($path in $xzPaths) {
            if (Test-Path $path) {
                $7zPath = $path
                break
            }
        }
        
        if ($7zPath) {
            Write-Host "Using 7-Zip for compression: $7zPath" -ForegroundColor Cyan
            # 7-Zip использует другой синтаксис для xz
            $process = Start-Process -FilePath $7zPath -ArgumentList @("a", "-txz", $MODEL_PATH, $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -ne 0) {
                throw "7-Zip compression failed with exit code $($process.ExitCode)"
            }
        } else {
            Write-Host ""
            Write-Host "ERROR: xz utility not found" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please install one of the following:" -ForegroundColor Yellow
            Write-Host "1. xz for Windows: https://tukaani.org/xz/" -ForegroundColor Cyan
            Write-Host "2. 7-Zip: https://www.7-zip.org/" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Or compress manually:" -ForegroundColor Yellow
            Write-Host "  xz -z -k $TEMP_MODEL_PATH" -ForegroundColor Gray
            Write-Host "  Then rename to: $MODEL_PATH" -ForegroundColor Gray
            Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue
            exit 1
        }
    } else {
        # Используем xz напрямую
        Write-Host "Using xz for compression..." -ForegroundColor Cyan
        $process = Start-Process -FilePath "xz" -ArgumentList @("-z", "-k", $TEMP_MODEL_PATH) -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "xz compression failed with exit code $($process.ExitCode)"
        }
        
        # Переименовываем сжатый файл
        $compressedTempPath = "$TEMP_MODEL_PATH.xz"
        if (Test-Path $compressedTempPath) {
            Move-Item -Path $compressedTempPath -Destination $MODEL_PATH -Force
        } else {
            throw "Compressed file not found: $compressedTempPath"
        }
    }
    
    # Удаляем временный несжатый файл
    Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue
    
    # Проверяем размер сжатого файла
    $compressedSize = (Get-Item $MODEL_PATH).Length
    $compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
    $compressionRatio = [math]::Round(($compressedSize / $fileSize) * 100, 1)
    
    Write-Host ""
    Write-Host "=== Compression complete ===" -ForegroundColor Green
    Write-Host "Compressed model: $MODEL_PATH" -ForegroundColor White
    Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
    Write-Host "Compression ratio: $compressionRatio%" -ForegroundColor White
    Write-Host ""
    Write-Host "Model downloaded and compressed successfully!" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Operation failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    # Очищаем временные файлы при ошибке
    if (Test-Path $TEMP_MODEL_PATH) {
        Remove-Item $TEMP_MODEL_PATH -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Alternative: Download manually from:" -ForegroundColor Yellow
    Write-Host "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF" -ForegroundColor Cyan
    Write-Host "File: Llama-3.2-3B-Instruct-Q2_K.gguf" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then compress with xz and rename to: $MODEL_PATH" -ForegroundColor Yellow
    exit 1
}
