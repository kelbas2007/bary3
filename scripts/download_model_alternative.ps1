# Альтернативный способ скачивания модели через huggingface-cli
# 
# Требования:
# - pip install huggingface_hub
# - Или используйте браузер для скачивания

param(
    [switch]$UseBrowser
)

Write-Host "=== Alternative Model Download Methods ===" -ForegroundColor Green
Write-Host ""

if ($UseBrowser) {
    Write-Host "Opening Hugging Face page in browser..." -ForegroundColor Cyan
    Start-Process "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/tree/main"
    Write-Host ""
    Write-Host "Please download the Q4_K_M.gguf file manually" -ForegroundColor Yellow
    Write-Host "Then rename it to model_v1.bin and place in assets/aka/models/" -ForegroundColor Yellow
    exit 0
}

Write-Host "Method 1: Using huggingface-cli (recommended)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Install huggingface-cli:" -ForegroundColor Yellow
Write-Host "  pip install huggingface_hub" -ForegroundColor White
Write-Host ""
Write-Host "Download model:" -ForegroundColor Yellow
Write-Host "  huggingface-cli download bartowski/Llama-3.2-3B-Instruct-GGUF --local-dir assets/aka/models --include '*.Q4_K_M.gguf'" -ForegroundColor White
Write-Host "  Rename the file to model_v1.bin" -ForegroundColor White
Write-Host ""

Write-Host "Method 2: Manual download" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open in browser:" -ForegroundColor Yellow
Write-Host "   https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/tree/main" -ForegroundColor White
Write-Host ""
Write-Host "2. Find file: Llama-3.2-3B-Instruct-Q4_K_M.gguf" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Download and rename to model_v1.bin" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Place in: assets/aka/models/model_v1.bin" -ForegroundColor Yellow
Write-Host ""

Write-Host "Method 3: Using Python script" -ForegroundColor Cyan
Write-Host ""
$pythonScript = @"
from huggingface_hub import hf_hub_download
import shutil

# Download model
model_path = hf_hub_download(
    repo_id="bartowski/Llama-3.2-3B-Instruct-GGUF",
    filename="Llama-3.2-3B-Instruct-Q4_K_M.gguf",
    local_dir="assets/aka/models"
)

# Rename to model_v1.bin
import os
target = "assets/aka/models/model_v1.bin"
if os.path.exists(model_path):
    shutil.move(model_path, target)
    print(f"Model saved to: {target}")
"@

$pythonScriptPath = "scripts/download_model_python.py"
$pythonScript | Out-File -FilePath $pythonScriptPath -Encoding UTF8
Write-Host "Python script created: $pythonScriptPath" -ForegroundColor Green
Write-Host "Run: python scripts/download_model_python.py" -ForegroundColor White
Write-Host ""

Write-Host "=== Quick Browser Download ===" -ForegroundColor Cyan
Write-Host "Run: .\scripts\download_model_alternative.ps1 -UseBrowser" -ForegroundColor Yellow
