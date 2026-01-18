# Скрипт для компиляции llama.cpp через WSL
# Автоматически находит NDK и запускает компиляцию

param(
    [string]$NDKPath
)

Write-Host "=== Compiling llama.cpp via WSL ===" -ForegroundColor Green
Write-Host ""

# Проверка WSL
$wsl = Get-Command wsl -ErrorAction SilentlyContinue
if (-not $wsl) {
    Write-Host "ERROR: WSL not found" -ForegroundColor Red
    Write-Host "Please install WSL2: wsl --install" -ForegroundColor Yellow
    exit 1
}

Write-Host "WSL found" -ForegroundColor Green

# Поиск NDK
if (-not $NDKPath) {
    if ($env:ANDROID_NDK_HOME) {
        $NDKPath = $env:ANDROID_NDK_HOME
    } elseif ($env:ANDROID_NDK_ROOT) {
        $NDKPath = $env:ANDROID_NDK_ROOT
    } else {
        # Поиск в стандартных местах
        $possiblePaths = @(
            "$env:LOCALAPPDATA\Android\Sdk\ndk",
            "$env:USERPROFILE\AppData\Local\Android\Sdk\ndk"
        )
        
        foreach ($basePath in $possiblePaths) {
            if (Test-Path $basePath) {
                $ndkVersions = Get-ChildItem $basePath -Directory | Sort-Object Name -Descending
                if ($ndkVersions) {
                    $NDKPath = $ndkVersions[0].FullName
                    Write-Host "Found NDK: $NDKPath" -ForegroundColor Cyan
                    break
                }
            }
        }
    }
}

if (-not $NDKPath -or -not (Test-Path $NDKPath)) {
    Write-Host "ERROR: Android NDK not found" -ForegroundColor Red
    Write-Host "Please install Android NDK or set ANDROID_NDK_HOME" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can install NDK via Android Studio:" -ForegroundColor Cyan
    Write-Host "  Tools > SDK Manager > SDK Tools > NDK (Side by side)" -ForegroundColor White
    exit 1
}

Write-Host "NDK Path: $NDKPath" -ForegroundColor Green

# Конвертируем Windows путь в WSL путь
$wslNDKPath = $NDKPath -replace '\\', '/' -replace '^([A-Z]):', '/mnt/$1' -replace '^([A-Z])', '$1' -replace ':', ''
$wslNDKPath = $wslNDKPath.ToLower()

Write-Host "WSL NDK Path: $wslNDKPath" -ForegroundColor Cyan
Write-Host ""

# Проверяем наличие скрипта
$scriptPath = "scripts/build_llama_android_standalone.sh"
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Starting compilation in WSL..." -ForegroundColor Cyan
Write-Host ""

# Запускаем компиляцию в WSL
$wslScriptPath = $scriptPath -replace '\\', '/'
$projectPath = (Get-Location).Path -replace '\\', '/' -replace '^([A-Z]):', '/mnt/$1' -replace '^([A-Z])', '$1' -replace ':', ''
$projectPath = $projectPath.ToLower()

Write-Host "Project path in WSL: $projectPath" -ForegroundColor Gray
Write-Host ""

# Выполняем компиляцию
wsl bash -c "
    cd '$projectPath' && \
    export ANDROID_NDK_HOME='$wslNDKPath' && \
    chmod +x '$wslScriptPath' && \
    bash '$wslScriptPath'
"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Compilation successful ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Library should be in: android/app/src/main/jniLibs/arm64-v8a/libllama.so" -ForegroundColor Cyan
    
    # Проверяем результат
    $libPath = "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
    if (Test-Path $libPath) {
        $size = (Get-Item $libPath).Length / 1MB
        Write-Host "✅ Library found: $([math]::Round($size, 2)) MB" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Library not found at expected location" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "=== Compilation failed ===" -ForegroundColor Red
    Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible issues:" -ForegroundColor Cyan
    Write-Host "  - NDK path incorrect" -ForegroundColor White
    Write-Host "  - CMake not installed in WSL" -ForegroundColor White
    Write-Host "  - Insufficient disk space" -ForegroundColor White
    Write-Host "  - Network issues (cloning llama.cpp)" -ForegroundColor White
}
