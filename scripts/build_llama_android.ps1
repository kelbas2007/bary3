# Скрипт для компиляции llama.cpp для Android (PowerShell для Windows)
# 
# Требования:
# - Android NDK (установлен и настроен)
# - CMake 3.18+ (должен быть в PATH)
# - Git
# - WSL или Docker для выполнения Linux команд

param(
    [string]$NDKPath = $env:ANDROID_NDK_HOME
)

Write-Host "=== Building llama.cpp for Android ===" -ForegroundColor Green

# Проверка NDK
if (-not $NDKPath) {
    $NDKPath = $env:ANDROID_NDK_ROOT
}

if (-not $NDKPath) {
    Write-Host "ERROR: ANDROID_NDK_HOME or ANDROID_NDK_ROOT not set" -ForegroundColor Red
    Write-Host "Please set one of these environment variables to your NDK path" -ForegroundColor Yellow
    Write-Host "Example: `$env:ANDROID_NDK_HOME = 'C:\Users\YourName\AppData\Local\Android\Sdk\ndk\25.2.9519653'" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $NDKPath)) {
    Write-Host "ERROR: NDK path does not exist: $NDKPath" -ForegroundColor Red
    exit 1
}

Write-Host "NDK Path: $NDKPath" -ForegroundColor Cyan

# Проверка CMake
$cmake = Get-Command cmake -ErrorAction SilentlyContinue
if (-not $cmake) {
    Write-Host "ERROR: CMake not found in PATH" -ForegroundColor Red
    Write-Host "Please install CMake and add it to PATH" -ForegroundColor Yellow
    exit 1
}

# Проверка Git
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "ERROR: Git not found in PATH" -ForegroundColor Red
    Write-Host "Please install Git and add it to PATH" -ForegroundColor Yellow
    exit 1
}

# Клонируем llama.cpp если еще не клонирован
if (-not (Test-Path "llama.cpp")) {
    Write-Host "Cloning llama.cpp repository..." -ForegroundColor Cyan
    git clone https://github.com/ggerganov/llama.cpp.git
    Push-Location llama.cpp
    git submodule update --init --recursive
    Pop-Location
}

# Проверяем наличие WSL или Docker
$wsl = Get-Command wsl -ErrorAction SilentlyContinue
$docker = Get-Command docker -ErrorAction SilentlyContinue

if ($wsl) {
    Write-Host "Using WSL for compilation..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=== IMPORTANT ===" -ForegroundColor Yellow
    Write-Host "This script requires WSL (Windows Subsystem for Linux) to compile llama.cpp" -ForegroundColor Yellow
    Write-Host "Please run the following commands in WSL:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  cd /mnt/c/flutter_projects/bary3" -ForegroundColor White
    Write-Host "  export ANDROID_NDK_HOME=/mnt/c/path/to/android-ndk" -ForegroundColor White
    Write-Host "  bash scripts/build_llama_android.sh" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use the Linux script directly in WSL" -ForegroundColor Yellow
} elseif ($docker) {
    Write-Host "Using Docker for compilation..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=== Docker approach ===" -ForegroundColor Yellow
    Write-Host "You can use a Docker container with Android NDK to compile:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  docker run -it --rm -v `"`${PWD}:/workspace`" -w /workspace android-ndk-builder bash scripts/build_llama_android.sh" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "=== ALTERNATIVE: Manual compilation ===" -ForegroundColor Yellow
    Write-Host "Since WSL/Docker are not available, you have these options:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Install WSL2 and use the Linux script" -ForegroundColor White
    Write-Host "2. Use a Linux VM or remote Linux machine" -ForegroundColor White
    Write-Host "3. Use pre-compiled libraries (if available)" -ForegroundColor White
    Write-Host "4. Use GitHub Actions for compilation" -ForegroundColor White
    Write-Host ""
    Write-Host "For now, creating placeholder structure..." -ForegroundColor Cyan
    
    # Создаем структуру директорий
    $jniLibsPath = "android\app\src\main\jniLibs"
    $architectures = @("arm64-v8a", "x86_64")
    
    foreach ($arch in $architectures) {
        $archPath = Join-Path $jniLibsPath $arch
        if (-not (Test-Path $archPath)) {
            New-Item -ItemType Directory -Path $archPath -Force | Out-Null
            Write-Host "Created directory: $archPath" -ForegroundColor Green
        }
        
        # Создаем README в каждой директории
        $readmePath = Join-Path $archPath "README.txt"
        @"
This directory should contain libllama.so compiled for $arch.

To compile:
1. Install WSL2 or use a Linux machine
2. Run: bash scripts/build_llama_android.sh
3. Copy the resulting libllama.so to this directory

Or download pre-compiled library from:
https://github.com/ggerganov/llama.cpp/releases
"@ | Out-File -FilePath $readmePath -Encoding UTF8
    }
    
    Write-Host ""
    Write-Host "Placeholder structure created. Please compile llama.cpp using one of the methods above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Next steps ===" -ForegroundColor Cyan
Write-Host "1. Compile llama.cpp using WSL, Docker, or Linux machine" -ForegroundColor White
Write-Host "2. Copy libllama.so to android/app/src/main/jniLibs/<arch>/" -ForegroundColor White
Write-Host "3. Update FFI types in llama_ffi_binding.dart if needed" -ForegroundColor White
