# Verify that data was successfully imported
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$packageName = "com.bary3.app"

Write-Host "=== Verifying Imported Data ===" -ForegroundColor Cyan
Write-Host ""

# Check app is running
$appRunning = & $adb shell pidof $packageName
if (-not $appRunning) {
    Write-Host "ERROR: App is not running!" -ForegroundColor Red
    Write-Host "Please start the app first" -ForegroundColor Yellow
    exit 1
}

Write-Host "App is running (PID: $appRunning)" -ForegroundColor Green
Write-Host ""

# Get Flutter logs to check for data
Write-Host "Checking Flutter logs for data indicators..." -ForegroundColor Yellow
$flutterLogs = & $adb logcat -d -s flutter:* | Select-Object -Last 50

# Check for transaction-related logs
$transactionLogs = $flutterLogs | Select-String -Pattern "transaction|Transaction" -CaseSensitive:$false
$piggyLogs = $flutterLogs | Select-String -Pattern "piggy|Piggy" -CaseSensitive:$false
$eventLogs = $flutterLogs | Select-String -Pattern "event|Event|planned" -CaseSensitive:$false
$lessonLogs = $flutterLogs | Select-String -Pattern "lesson|Lesson" -CaseSensitive:$false

Write-Host ""
Write-Host "=== Data Indicators in Logs ===" -ForegroundColor Cyan

if ($transactionLogs) {
    Write-Host "Found transaction references: $($transactionLogs.Count)" -ForegroundColor Green
} else {
    Write-Host "No transaction references found" -ForegroundColor Yellow
}

if ($piggyLogs) {
    Write-Host "Found piggy bank references: $($piggyLogs.Count)" -ForegroundColor Green
} else {
    Write-Host "No piggy bank references found" -ForegroundColor Yellow
}

if ($eventLogs) {
    Write-Host "Found event references: $($eventLogs.Count)" -ForegroundColor Green
} else {
    Write-Host "No event references found" -ForegroundColor Yellow
}

if ($lessonLogs) {
    Write-Host "Found lesson references: $($lessonLogs.Count)" -ForegroundColor Green
} else {
    Write-Host "No lesson references found" -ForegroundColor Yellow
}

# Check for import-related messages
Write-Host ""
Write-Host "=== Import Status ===" -ForegroundColor Cyan
$importMessages = $flutterLogs | Select-String -Pattern "import|Import|save|Save|load|Load" -CaseSensitive:$false
if ($importMessages) {
    Write-Host "Found import/save operations:" -ForegroundColor Green
    $importMessages | Select-Object -First 5 | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor White 
    }
}

# Check for any errors
Write-Host ""
Write-Host "=== Error Check ===" -ForegroundColor Cyan
$appErrors = $flutterLogs | Select-String -Pattern "Error|Exception|Failed" -CaseSensitive:$false
if ($appErrors) {
    Write-Host "Found errors:" -ForegroundColor Red
    $appErrors | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor Red 
    }
} else {
    Write-Host "No errors found in app logs" -ForegroundColor Green
}

# Final summary
Write-Host ""
Write-Host "=== Final Verification ===" -ForegroundColor Cyan
Write-Host "To verify data was imported, please check in the app:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Balance Screen:" -ForegroundColor White
Write-Host "   - Should show 13 transactions" -ForegroundColor Gray
Write-Host "   - Should show balance with income/expenses" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Piggy Banks Screen:" -ForegroundColor White
Write-Host "   - Should show 3 piggy banks" -ForegroundColor Gray
Write-Host "   - One should be completed (100%)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Calendar Screen:" -ForegroundColor White
Write-Host "   - Should show 4 planned events" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Lessons Screen:" -ForegroundColor White
Write-Host "   - Should show 5 completed lessons" -ForegroundColor Gray
Write-Host "   - Player level should be 2" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Settings Screen:" -ForegroundColor White
Write-Host "   - Check player profile (XP: 350, Level: 2)" -ForegroundColor Gray
Write-Host ""

if ($appErrors) {
    Write-Host "Status: ERRORS FOUND - Please check logs" -ForegroundColor Red
} else {
    Write-Host "Status: NO ERRORS - App is running normally" -ForegroundColor Green
    Write-Host "Please verify data manually in the app" -ForegroundColor Yellow
}

Write-Host ""
