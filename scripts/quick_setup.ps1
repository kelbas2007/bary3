# Быстрая настройка для разработки без реальной компиляции
# 
# Создает структуру и placeholder файлы для разработки

Write-Host "=== Quick Setup for AKA Local LLM Development ===" -ForegroundColor Green
Write-Host ""

# Создаем структуру директорий
Write-Host "Creating directory structure..." -ForegroundColor Cyan

$directories = @(
    "android\app\src\main\jniLibs\arm64-v8a",
    "android\app\src\main\jniLibs\x86_64",
    "ios\Frameworks",
    "assets\aka\models"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    }
}

# Создаем README файлы
Write-Host ""
Write-Host "Creating README files..." -ForegroundColor Cyan

$jniLibsReadme = @"
# Native Libraries for llama.cpp

This directory should contain libllama.so compiled for the target architecture.

## For Development (Stub Mode)

The FFI binding works in stub mode without the actual library.
This allows development and testing of the integration code.

## For Production

1. Compile llama.cpp using:
   - WSL: bash scripts/build_llama_android.sh
   - Or download pre-compiled from GitHub releases

2. Place libllama.so in the appropriate architecture folder:
   - arm64-v8a/ for ARM64 devices
   - x86_64/ for x86_64 emulators

3. Update FFI types in llama_ffi_binding.dart based on actual function signatures
"@

$jniLibsReadme | Out-File -FilePath "android\app\src\main\jniLibs\README.md" -Encoding UTF8

$modelsReadme = @"
# AKA Model Files

This directory contains the local LLM model files.

## Model v1

- File: model_v1.bin
- Model: Llama 3.2 3B Q4_K_M
- Size: ~2GB
- Format: GGUF

## Download

Run: .\scripts\download_model.ps1

Or download manually from:
https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF

## Note

Model files are not included in git due to size.
They must be added manually or through CI/CD.
"@

$modelsReadme | Out-File -FilePath "assets\aka\models\README.md" -Encoding UTF8

# Создаем .gitkeep для пустых директорий
Write-Host ""
Write-Host "Creating .gitkeep files..." -ForegroundColor Cyan

$gitkeepDirs = @(
    "android\app\src\main\jniLibs\arm64-v8a",
    "android\app\src\main\jniLibs\x86_64"
)

foreach ($dir in $gitkeepDirs) {
    $gitkeep = Join-Path $dir ".gitkeep"
    if (-not (Test-Path $gitkeep)) {
        "" | Out-File -FilePath $gitkeep -Encoding UTF8
        Write-Host "  Created: $gitkeep" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Current status:" -ForegroundColor Cyan
Write-Host "  ✅ Directory structure created" -ForegroundColor White
Write-Host "  ✅ README files created" -ForegroundColor White
Write-Host "  ✅ FFI binding ready (stub mode)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. For development: Code works in stub mode" -ForegroundColor White
Write-Host "  2. For production: Compile llama.cpp and add model" -ForegroundColor White
Write-Host ""
Write-Host "To compile llama.cpp:" -ForegroundColor Yellow
Write-Host "  - Use WSL: bash scripts/build_llama_android.sh" -ForegroundColor Gray
Write-Host "  - Or use GitHub Actions workflow" -ForegroundColor Gray
Write-Host ""
Write-Host "To download model:" -ForegroundColor Yellow
Write-Host "  .\scripts\download_model.ps1" -ForegroundColor Gray
