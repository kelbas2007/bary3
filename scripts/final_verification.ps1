# Final verification of imported data
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"

Write-Host "=== Final Data Verification ===" -ForegroundColor Cyan
Write-Host ""

# Get all Flutter logs
Write-Host "Analyzing Flutter logs..." -ForegroundColor Yellow
$allLogs = & $adb logcat -d -s flutter:* | Select-Object -Last 100

# Check for data generation messages
$dataMessages = $allLogs | Select-String -Pattern "Создано|created|транзакц|копилк|событи|урок|Transaction|Piggy|Event|Lesson|Progress" -CaseSensitive:$false

Write-Host "Data-related messages found: $($dataMessages.Count)" -ForegroundColor $(if ($dataMessages.Count -gt 0) { "Green" } else { "Yellow" })
if ($dataMessages) {
    $dataMessages | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
}

# Check for errors
Write-Host ""
Write-Host "Error check:" -ForegroundColor Yellow
$errors = $allLogs | Select-String -Pattern "Error|Exception|Failed" -CaseSensitive:$false
if ($errors) {
    Write-Host "Errors found:" -ForegroundColor Red
    $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors found" -ForegroundColor Green
}

# Check print statements from generator
Write-Host ""
Write-Host "Generator output:" -ForegroundColor Yellow
$generatorOutput = $allLogs | Select-String -Pattern "Тестовые данные|generateWeeklyData|WeeklyTestDataGenerator" -CaseSensitive:$false
if ($generatorOutput) {
    Write-Host "Generator was executed:" -ForegroundColor Green
    $generatorOutput | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
} else {
    Write-Host "No generator output found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($dataMessages.Count -gt 5 -and -not $errors) {
    Write-Host "Status: LIKELY SUCCESS - Data appears to be imported" -ForegroundColor Green
    Write-Host "Please verify in the app:" -ForegroundColor Yellow
    Write-Host "  - Balance screen should show transactions" -ForegroundColor White
    Write-Host "  - Piggy Banks should show 3 banks" -ForegroundColor White
    Write-Host "  - Calendar should show 4 events" -ForegroundColor White
} elseif ($generatorOutput) {
    Write-Host "Status: GENERATOR EXECUTED - Check app manually" -ForegroundColor Yellow
} else {
    Write-Host "Status: UNCLEAR - May need to retry import" -ForegroundColor Yellow
}

Write-Host ""
