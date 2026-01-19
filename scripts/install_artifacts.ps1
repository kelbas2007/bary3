# Автоматический скрипт для скачивания и размещения артефактов
param([string]$RunId = "21119687068")

Write-Host "=== АВТОМАТИЧЕСКАЯ УСТАНОВКА АРТЕФАКТОВ ===" -ForegroundColor Green
Write-Host ""

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI не установлен" -ForegroundColor Red
    exit 1
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ GitHub CLI не авторизован" -ForegroundColor Red
    exit 1
}

Write-Host "✅ GitHub CLI готов" -ForegroundColor Green
Write-Host "Скачивание артефактов из run $RunId..." -ForegroundColor Yellow

if (Test-Path "artifacts") { Remove-Item -Path "artifacts" -Recurse -Force }
gh run download $RunId --dir artifacts

if (-not (Test-Path "artifacts")) {
    Write-Host "❌ Ошибка скачивания" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Артефакты скачаны" -ForegroundColor Green
Write-Host "Распаковка..." -ForegroundColor Yellow

$zipFiles = Get-ChildItem -Path artifacts -Filter "*.zip" -Recurse
foreach ($zip in $zipFiles) {
    $extractPath = Join-Path $zip.DirectoryName $zip.BaseName
    Expand-Archive -Path $zip.FullName -DestinationPath $extractPath -Force
    Write-Host "  ✅ $($zip.Name)" -ForegroundColor Green
}

Write-Host "Размещение Android библиотек..." -ForegroundColor Yellow
$androidLibs = Get-ChildItem -Path artifacts -Filter "libllama.so" -Recurse
foreach ($lib in $androidLibs) {
    if ($lib.Directory.Name -match "arm64|aarch64") {
        $targetDir = "android\app\src\main\jniLibs\arm64-v8a"
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Copy-Item -Path $lib.FullName -Destination "$targetDir\libllama.so" -Force
        $size = [math]::Round((Get-Item "$targetDir\libllama.so").Length / 1MB, 2)
        Write-Host "  ✅ Android: $targetDir\libllama.so ($size MB)" -ForegroundColor Green
        break
    }
}

Write-Host "Размещение iOS framework..." -ForegroundColor Yellow
$iosFramework = Get-ChildItem -Path artifacts -Filter "llama.framework" -Recurse -Directory | Select-Object -First 1
if ($iosFramework) {
    $targetDir = "ios\Frameworks"
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    $targetPath = "$targetDir\llama.framework"
    if (Test-Path $targetPath) { Remove-Item -Path $targetPath -Recurse -Force }
    Copy-Item -Path $iosFramework.FullName -Destination $targetPath -Recurse -Force
    Write-Host "  ✅ iOS: $targetPath" -ForegroundColor Green
}

Write-Host "=== ПРОВЕРКА ===" -ForegroundColor Cyan
$androidLib = "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
$iosFramework = "ios\Frameworks\llama.framework\llama"

if (Test-Path $androidLib) {
    $size = [math]::Round((Get-Item $androidLib).Length / 1MB, 2)
    Write-Host "✅ Android: $androidLib ($size MB)" -ForegroundColor Green
} else {
    Write-Host "❌ Android: не найдена" -ForegroundColor Red
}

if (Test-Path $iosFramework) {
    Write-Host "✅ iOS: $iosFramework" -ForegroundColor Green
} else {
    Write-Host "❌ iOS: не найден" -ForegroundColor Red
}

Write-Host "=== ГОТОВО ===" -ForegroundColor Green
