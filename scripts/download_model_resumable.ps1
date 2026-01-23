# Улучшенный скрипт для скачивания модели с поддержкой возобновления
# Использует Range requests для продолжения прерванной загрузки

$ErrorActionPreference = "Continue"

Write-Host "=== Downloading Llama 3.2 3B Q3_K_S model (with resume support) ===" -ForegroundColor Green

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

# Проверяем, существует ли уже сжатая модель
if (Test-Path $MODEL_PATH) {
    $fileSize = (Get-Item $MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "✅ Compressed model already exists: $MODEL_PATH" -ForegroundColor Green
    Write-Host "   Size: $fileSizeMB MB" -ForegroundColor Cyan
    Write-Host "   Model is ready to use!" -ForegroundColor Green
    exit 0
}

# Функция для скачивания с поддержкой возобновления
function Save-FileWithResume {
    param(
        [string]$Url,
        [string]$OutputPath,
        [int]$ChunkSize = 10MB
    )
    
    $existingSize = 0
    if (Test-Path $OutputPath) {
        $existingSize = (Get-Item $OutputPath).Length
        Write-Host "Resuming download from $([math]::Round($existingSize / 1MB, 2)) MB" -ForegroundColor Yellow
    }
    
    try {
        # Получаем размер файла с сервера
        $headRequest = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing
        $totalSize = [int64]$headRequest.Headers['Content-Length']
        
        if ($totalSize -eq 0) {
            # Если Content-Length не доступен, пробуем другой способ
            Write-Host "Content-Length not available, using standard download..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
            return
        }
        
        Write-Host "Total file size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan
        
        if ($existingSize -ge $totalSize) {
            Write-Host "File already complete!" -ForegroundColor Green
            return
        }
        
        # Открываем файл для дозаписи
        $fileStream = [System.IO.File]::OpenWrite($OutputPath)
        $fileStream.Seek($existingSize, [System.IO.SeekOrigin]::Begin) | Out-Null
        
        $currentSize = $existingSize
        $buffer = New-Object byte[] $ChunkSize
        
        while ($currentSize -lt $totalSize) {
            $remaining = $totalSize - $currentSize
            $requestSize = [Math]::Min($ChunkSize, $remaining)
            
            # Создаем запрос с Range header
            $request = [System.Net.HttpWebRequest]::Create($Url)
            $request.Method = "GET"
            $request.AddRange($currentSize, $currentSize + $requestSize - 1)
            
            try {
                $response = $request.GetResponse()
                $responseStream = $response.GetResponseStream()
                
                $bytesRead = 0
                do {
                    $bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)
                    if ($bytesRead -gt 0) {
                        $fileStream.Write($buffer, 0, $bytesRead)
                        $currentSize += $bytesRead
                        
                        $progress = [math]::Round(($currentSize / $totalSize) * 100, 1)
                        $currentMB = [math]::Round($currentSize / 1MB, 2)
                        $totalMB = [math]::Round($totalSize / 1MB, 2)
                        
                        Write-Progress -Activity "Downloading model" -Status "$progress% ($currentMB MB / $totalMB MB)" -PercentComplete $progress
                    }
                } while ($bytesRead -gt 0)
                
                $responseStream.Close()
                $response.Close()
            } catch {
                Write-Host "Error downloading chunk: $($_.Exception.Message)" -ForegroundColor Red
                throw
            }
        }
        
        $fileStream.Close()
        Write-Progress -Activity "Downloading model" -Completed
        
        Write-Host "Download complete!" -ForegroundColor Green
        
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

Write-Host "Starting download..." -ForegroundColor Cyan
Write-Host "URL: $MODEL_URL" -ForegroundColor Gray
Write-Host ""

try {
    # Скачиваем модель с поддержкой возобновления
    Save-FileWithResume -Url $MODEL_URL -OutputPath $TEMP_MODEL_PATH
    
    $fileSize = (Get-Item $TEMP_MODEL_PATH).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
    
    Write-Host ""
    Write-Host "✅ Download complete: $fileSizeMB MB ($fileSizeGB GB)" -ForegroundColor Green
    
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
        Write-Host ""
        Write-Host "Please install one of:" -ForegroundColor Yellow
        Write-Host "1. xz for Windows: https://tukaani.org/xz/" -ForegroundColor Cyan
        Write-Host "2. 7-Zip: https://www.7-zip.org/" -ForegroundColor Cyan
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
    } else {
        # Fallback к старому методу
        Write-Host "Smart compression script not found, using basic compression..." -ForegroundColor Yellow
        & "$PSScriptRoot\compress_model_fixed.ps1"
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️ Compression was not effective or failed" -ForegroundColor Yellow
        Write-Host "Original file is kept at: $TEMP_MODEL_PATH" -ForegroundColor Yellow
        Write-Host "You can try compressing manually or use the uncompressed file" -ForegroundColor Yellow
        exit 1
    }
    
    # Проверяем результат (скрипт уже показал результаты)
    if (Test-Path $MODEL_PATH) {
        $compressedSize = (Get-Item $MODEL_PATH).Length
        $compressedSizeMB = [math]::Round($compressedSize / 1MB, 2)
        
        Write-Host ""
        Write-Host "=== ✅ SUCCESS ===" -ForegroundColor Green
        Write-Host "Compressed model: $MODEL_PATH" -ForegroundColor White
        Write-Host "Compressed size: $compressedSizeMB MB" -ForegroundColor White
        Write-Host ""
        Write-Host "🎉 Model is ready to use in the app!" -ForegroundColor Green
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
    
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "1. Run this script again to resume download" -ForegroundColor Cyan
    Write-Host "2. Download manually from: $MODEL_URL" -ForegroundColor Cyan
    Write-Host "3. Use a download manager (IDM, FDM, etc.)" -ForegroundColor Cyan
    exit 1
}
