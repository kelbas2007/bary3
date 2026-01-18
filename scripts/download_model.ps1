# Скрипт для скачивания модели Llama 3.2 3B Q4_K_M (PowerShell для Windows)
# 
# Требования:
# - PowerShell 5.1+ или PowerShell Core
# - Достаточно места на диске (~2GB)

param(
    [switch]$Force
)

Write-Host "=== Downloading Llama 3.2 3B Q4_K_M model ===" -ForegroundColor Green

$MODEL_DIR = "assets\aka\models"
$MODEL_NAME = "model_v1.bin"
# Прямая ссылка на модель (может потребоваться обновление)
# Альтернативные источники:
# 1. https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF
# 2. https://huggingface.co/QuantFactory/Llama-3.2-3B-Instruct-GGUF
# 3. Используйте huggingface-cli для скачивания
$MODEL_URL = "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
$EXPECTED_SIZE = 2000000000 # ~2GB

# Создаем директорию если не существует
if (-not (Test-Path $MODEL_DIR)) {
    New-Item -ItemType Directory -Path $MODEL_DIR -Force | Out-Null
    Write-Host "Created directory: $MODEL_DIR" -ForegroundColor Green
}

$MODEL_PATH = Join-Path $MODEL_DIR $MODEL_NAME

# Проверяем, существует ли уже модель
if ((Test-Path $MODEL_PATH) -and -not $Force) {
    $fileSize = (Get-Item $MODEL_PATH).Length
    Write-Host "Model already exists: $MODEL_PATH" -ForegroundColor Yellow
    Write-Host "File size: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Cyan
    
    $response = Read-Host "Do you want to re-download? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Skipping download" -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $MODEL_PATH -Force
}

Write-Host "Downloading model from Hugging Face..." -ForegroundColor Cyan
Write-Host "URL: $MODEL_URL" -ForegroundColor Gray
Write-Host "Destination: $MODEL_PATH" -ForegroundColor Gray
Write-Host "Expected size: ~2GB" -ForegroundColor Yellow
Write-Host ""

# Проверяем доступное место на диске
$drive = (Get-Item $MODEL_DIR).PSDrive
$freeSpace = $drive.Free
if ($freeSpace -lt $EXPECTED_SIZE) {
    Write-Host "WARNING: Not enough free space on disk" -ForegroundColor Red
    Write-Host "Free space: $([math]::Round($freeSpace / 1GB, 2)) GB" -ForegroundColor Yellow
    Write-Host "Required: ~2 GB" -ForegroundColor Yellow
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
    
    # Скачиваем с прогресс-баром
    Invoke-WebRequest -Uri $MODEL_URL -OutFile $MODEL_PATH -UseBasicParsing
    
    # Проверяем размер файла
    $fileSize = (Get-Item $MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
    
    Write-Host ""
    Write-Host "=== Download complete ===" -ForegroundColor Green
    Write-Host "Model saved to: $MODEL_PATH" -ForegroundColor White
    Write-Host "File size: $fileSizeMB MB ($fileSizeGB GB)" -ForegroundColor White
    
    if ($fileSize -lt ($EXPECTED_SIZE * 0.9)) {
        Write-Host ""
        Write-Host "WARNING: File size is less than expected" -ForegroundColor Yellow
        Write-Host "The download might be incomplete. Please check the file." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "Model downloaded successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Download failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Download manually from:" -ForegroundColor Yellow
    Write-Host "https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then copy the file to: $MODEL_PATH" -ForegroundColor Yellow
    exit 1
}
