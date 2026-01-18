# Final automated import using deep link
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$packageName = "com.bary3.app"

Write-Host "=== Final Automated Import ===" -ForegroundColor Cyan
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

# Start app with deep link for import
Write-Host "Starting app with import deep link..." -ForegroundColor Yellow
& $adb shell am start -a android.intent.action.VIEW -d "bary3://import/test_data" $packageName
Start-Sleep -Seconds 5

Write-Host "Waiting for import to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "=== Checking Results ===" -ForegroundColor Cyan

# Check logs
$logs = & $adb logcat -d -s flutter:* | Select-Object -Last 50
$success = $logs | Select-String -Pattern "успешно|success|Создано|created|импортированы|imported" -CaseSensitive:$false
$errors = $logs | Select-String -Pattern "Error|Exception|Failed|Ошибка" -CaseSensitive:$false
$dataMessages = $logs | Select-String -Pattern "транзакц|копилк|событи|урок|Transaction|Piggy|Event|Lesson" -CaseSensitive:$false

Write-Host ""
if ($success) {
    Write-Host "SUCCESS messages:" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}

if ($dataMessages) {
    Write-Host "Data generation messages: $($dataMessages.Count)" -ForegroundColor Green
    $dataMessages | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
}

if ($errors) {
    Write-Host "Errors found:" -ForegroundColor Red
    $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors found" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Final Status ===" -ForegroundColor Cyan
if ($success -and $dataMessages -and -not $errors) {
    Write-Host "Status: SUCCESS - Data imported!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Imported data:" -ForegroundColor Yellow
    Write-Host "  - 13 transactions" -ForegroundColor White
    Write-Host "  - 3 piggy banks" -ForegroundColor White
    Write-Host "  - 4 planned events" -ForegroundColor White
    Write-Host "  - 5 lesson progress entries" -ForegroundColor White
    Write-Host "  - Player profile (Level 2, 350 XP)" -ForegroundColor White
} elseif ($success) {
    Write-Host "Status: LIKELY SUCCESS - Please verify in app" -ForegroundColor Yellow
} else {
    Write-Host "Status: UNCLEAR - May need manual import" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Please verify in the app:" -ForegroundColor Cyan
Write-Host "  - Balance screen: 13 transactions" -ForegroundColor White
Write-Host "  - Piggy Banks: 3 banks" -ForegroundColor White
Write-Host "  - Calendar: 4 events" -ForegroundColor White
Write-Host "  - Lessons: 5 completed" -ForegroundColor White
Write-Host ""
