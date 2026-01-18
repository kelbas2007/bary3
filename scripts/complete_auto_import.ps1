# Complete automated import using Flutter helper
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$packageName = "com.bary3.app"

Write-Host "=== Complete Automated Import ===" -ForegroundColor Cyan
Write-Host ""

# Check emulator
$devices = & $adb devices 2>&1
$deviceConnected = $devices | Select-String -Pattern "device$"
if (-not $deviceConnected) {
    Write-Host "ERROR: Emulator not connected!" -ForegroundColor Red
    exit 1
}
Write-Host "Emulator connected" -ForegroundColor Green

# Clear logcat
Write-Host "Clearing logcat..." -ForegroundColor Yellow
& $adb logcat -c

# Run Flutter import helper
Write-Host ""
Write-Host "Running automated import..." -ForegroundColor Yellow
Write-Host "This will import all test data directly via StorageService" -ForegroundColor Cyan
Write-Host ""

cd C:\flutter_projects\bary3
flutter run -d emulator-5554 lib/main_import_helper.dart 2>&1 | Tee-Object -Variable output

# Check output for success
$success = $output | Select-String -Pattern "All data imported successfully|Data import completed"
$errors = $output | Select-String -Pattern "Error|Exception|Failed" -CaseSensitive:$false

Write-Host ""
Write-Host "=== Import Results ===" -ForegroundColor Cyan

if ($success) {
    Write-Host "Import completed successfully!" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
} else {
    Write-Host "Import status unclear" -ForegroundColor Yellow
}

if ($errors) {
    Write-Host ""
    Write-Host "Errors found:" -ForegroundColor Red
    $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

# Check logs
Write-Host ""
Write-Host "Checking app logs..." -ForegroundColor Yellow
$logs = & $adb logcat -d -s flutter:* | Select-Object -Last 30
$logErrors = $logs | Select-String -Pattern "Error|Exception" -CaseSensitive:$false

if ($logErrors) {
    Write-Host "Errors in logs:" -ForegroundColor Red
    $logErrors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors in logs" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan
Write-Host "Please check the app to verify:" -ForegroundColor Yellow
Write-Host "  - Balance screen: 13 transactions" -ForegroundColor White
Write-Host "  - Piggy Banks: 3 banks" -ForegroundColor White
Write-Host "  - Calendar: 4 events" -ForegroundColor White
Write-Host "  - Lessons: 5 completed" -ForegroundColor White
Write-Host ""

if ($success -and -not $errors) {
    Write-Host "Status: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "Status: CHECK MANUALLY" -ForegroundColor Yellow
}

Write-Host ""
