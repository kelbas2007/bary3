# Check for errors after import
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$packageName = "com.bary3.app"

Write-Host "=== Post-Import Error Check ===" -ForegroundColor Cyan
Write-Host ""

# Get recent logcat (last 200 lines, filtered for our app)
Write-Host "Checking recent logs..." -ForegroundColor Yellow
$allLogs = & $adb logcat -d | Select-Object -Last 200
$logs = $allLogs | Select-String -Pattern "bary3|flutter|com.bary3" -CaseSensitive:$false

# Check for errors (only from our app)
$errors = $logs | Select-String -Pattern "Error|Exception|FATAL|Crash|Failed" -CaseSensitive:$false
$flutterErrors = $logs | Select-String -Pattern "flutter.*Error|flutter.*Exception" -CaseSensitive:$false
$importErrors = $logs | Select-String -Pattern "import.*Error|import.*Exception|import.*Failed|Error.*import" -CaseSensitive:$false

Write-Host ""
Write-Host "=== Error Analysis ===" -ForegroundColor Cyan

if ($errors) {
    Write-Host "Found errors in logs:" -ForegroundColor Red
    $errors | Select-Object -First 10 | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor Red 
    }
} else {
    Write-Host "No general errors found" -ForegroundColor Green
}

if ($flutterErrors) {
    Write-Host ""
    Write-Host "Found Flutter errors:" -ForegroundColor Red
    $flutterErrors | Select-Object -First 10 | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor Red 
    }
} else {
    Write-Host "No Flutter errors found" -ForegroundColor Green
}

if ($importErrors) {
    Write-Host ""
    Write-Host "Found import-specific errors:" -ForegroundColor Red
    $importErrors | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor Red 
    }
} else {
    Write-Host "No import errors found" -ForegroundColor Green
}

# Check for success messages
Write-Host ""
Write-Host "=== Success Indicators ===" -ForegroundColor Cyan
$successMessages = $logs | Select-String -Pattern "import.*success|import.*Success|imported|Import.*success" -CaseSensitive:$false
if ($successMessages) {
    Write-Host "Found success messages:" -ForegroundColor Green
    $successMessages | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor Green 
    }
} else {
    Write-Host "No explicit success messages found" -ForegroundColor Yellow
}

# Check app state
Write-Host ""
Write-Host "=== App State Check ===" -ForegroundColor Cyan
$currentActivity = & $adb shell dumpsys window | Select-String -Pattern "mCurrentFocus"
Write-Host "Current activity: $currentActivity" -ForegroundColor White

# Check if app is running
$appRunning = & $adb shell pidof $packageName
if ($appRunning) {
    Write-Host "App is running (PID: $appRunning)" -ForegroundColor Green
} else {
    Write-Host "App is not running" -ForegroundColor Yellow
}

# Save detailed log
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "C:\flutter_projects\bary3\scripts\post_import_check_$timestamp.txt"
$logs | Out-File $logFile -Encoding UTF8

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($errors -or $flutterErrors -or $importErrors) {
    Write-Host "Status: ERRORS DETECTED" -ForegroundColor Red
    Write-Host "Please check the log file for details" -ForegroundColor Yellow
} else {
    Write-Host "Status: NO ERRORS DETECTED" -ForegroundColor Green
    Write-Host "Import appears to be successful!" -ForegroundColor Green
}
Write-Host "Detailed log: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please verify in the app:" -ForegroundColor Yellow
Write-Host "  - Balance screen should show transactions" -ForegroundColor White
Write-Host "  - Piggy Banks should show 3 banks" -ForegroundColor White
Write-Host "  - Calendar should show 4 events" -ForegroundColor White
Write-Host "  - Lessons should show 5 completed" -ForegroundColor White
Write-Host ""
