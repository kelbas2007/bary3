# Скрипт для проверки FFI сигнатур после компиляции библиотеки
# 
# Использует nm (если доступен через WSL) или предоставляет инструкции

param(
    [string]$LibraryPath
)

Write-Host "=== Checking FFI signatures for llama.cpp ===" -ForegroundColor Green

if (-not $LibraryPath) {
    Write-Host "Usage: .\scripts\check_ffi_signatures.ps1 -LibraryPath <path_to_libllama.so>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example:" -ForegroundColor White
    Write-Host "  .\scripts\check_ffi_signatures.ps1 -LibraryPath android\app\src\main\jniLibs\arm64-v8a\libllama.so" -ForegroundColor Gray
    exit 1
}

if (-not (Test-Path $LibraryPath)) {
    Write-Host "ERROR: Library not found: $LibraryPath" -ForegroundColor Red
    exit 1
}

Write-Host "Library: $LibraryPath" -ForegroundColor Cyan
Write-Host ""

# Проверяем наличие nm через WSL
$wsl = Get-Command wsl -ErrorAction SilentlyContinue

if ($wsl) {
    Write-Host "Using WSL to check symbols..." -ForegroundColor Cyan
    Write-Host ""
    
    # Конвертируем Windows путь в WSL путь
    $wslPath = $LibraryPath -replace '\\', '/' -replace '^([A-Z]):', '/mnt/$1' -replace '^([A-Z])', '$1' -replace ':', ''
    $wslPath = $wslPath.ToLower()
    
    Write-Host "Checking exported symbols..." -ForegroundColor Cyan
    wsl nm -D $wslPath | Select-String "llama" | ForEach-Object {
        Write-Host $_.Line -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "=== Analysis ===" -ForegroundColor Cyan
    Write-Host "Look for these key functions:" -ForegroundColor Yellow
    Write-Host "  - llama_model_default_params" -ForegroundColor White
    Write-Host "  - llama_load_model_from_file" -ForegroundColor White
    Write-Host "  - llama_context_default_params" -ForegroundColor White
    Write-Host "  - llama_new_context_with_model" -ForegroundColor White
    Write-Host "  - llama_tokenize" -ForegroundColor White
    Write-Host "  - llama_decode" -ForegroundColor White
    Write-Host "  - llama_sample_token (or llama_sample)" -ForegroundColor White
    Write-Host "  - llama_get_logits" -ForegroundColor White
    Write-Host "  - llama_free_model" -ForegroundColor White
    Write-Host "  - llama_free_context" -ForegroundColor White
} else {
    Write-Host "WSL not available. Manual check required." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To check symbols manually:" -ForegroundColor Cyan
    Write-Host "1. Install WSL2 or use a Linux machine" -ForegroundColor White
    Write-Host "2. Run: nm -D $LibraryPath | grep llama" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use online tools:" -ForegroundColor Cyan
    Write-Host "- https://github.com/NationalSecurityAgency/ghidra" -ForegroundColor White
    Write-Host "- objdump (if available)" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Next steps ===" -ForegroundColor Cyan
Write-Host "1. Compare found symbols with FFI types in llama_ffi_binding.dart" -ForegroundColor White
Write-Host "2. Update FFI typedefs if function names differ" -ForegroundColor White
Write-Host "3. Check function signatures in llama.h header file" -ForegroundColor White
Write-Host "4. Update implementation in llama_ffi_binding.dart" -ForegroundColor White
