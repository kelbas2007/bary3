# Automated import and error checking script
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$jsonFile = "C:\flutter_projects\bary3\scripts\weekly_test_data.json"
$packageName = "com.bary3.app"

Write-Host "=== Automated Import and Error Check ===" -ForegroundColor Cyan
Write-Host ""

# Check emulator
$devices = & $adb devices 2>&1
$deviceConnected = $devices | Select-String -Pattern "device$"
if (-not $deviceConnected) {
    Write-Host "ERROR: Emulator not connected!" -ForegroundColor Red
    exit 1
}
Write-Host "Emulator connected" -ForegroundColor Green

# Check file
if (-not (Test-Path $jsonFile)) {
    Write-Host "ERROR: JSON file not found!" -ForegroundColor Red
    exit 1
}
Write-Host "JSON file found" -ForegroundColor Green

# Copy file to device
Write-Host ""
Write-Host "Copying JSON to device..." -ForegroundColor Yellow
& $adb push $jsonFile /sdcard/weekly_test_data.json
if ($LASTEXITCODE -eq 0) {
    Write-Host "File copied to /sdcard/weekly_test_data.json" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to copy file" -ForegroundColor Red
    exit 1
}

# Read JSON content
$jsonContent = Get-Content $jsonFile -Raw -Encoding UTF8

# Start app
Write-Host ""
Write-Host "Starting app..." -ForegroundColor Yellow
& $adb shell am start -n $packageName/com.example.bary3.MainActivity
Start-Sleep -Seconds 3

# Clear logcat
Write-Host "Clearing logcat..." -ForegroundColor Yellow
& $adb logcat -c

Write-Host ""
Write-Host "=== IMPORT INSTRUCTIONS ===" -ForegroundColor Cyan
Write-Host "1. In the app, go to Settings (last tab)" -ForegroundColor White
Write-Host "2. Find Export/Import section" -ForegroundColor White
Write-Host "3. Tap Import Data" -ForegroundColor White
Write-Host "4. Paste the JSON content (it is in clipboard)" -ForegroundColor White
Write-Host "5. Tap Import" -ForegroundColor White
Write-Host ""
Write-Host "Waiting 30 seconds for you to complete import..." -ForegroundColor Yellow
Write-Host ""

# Copy JSON to clipboard (for easy paste)
$jsonContent | Set-Clipboard
Write-Host "JSON content copied to clipboard - ready to paste!" -ForegroundColor Green

# Wait for import
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "=== Checking for errors ===" -ForegroundColor Cyan

# Get recent logcat
$logs = & $adb logcat -d -s flutter:* AndroidRuntime:E *:E | Select-Object -Last 50

# Check for errors
$errors = $logs | Select-String -Pattern "Error|Exception|FATAL|Crash" -CaseSensitive:$false
$flutterErrors = $logs | Select-String -Pattern "flutter.*Error" -CaseSensitive:$false

Write-Host ""
if ($errors -or $flutterErrors) {
    Write-Host "ERRORS FOUND:" -ForegroundColor Red
    if ($errors) {
        Write-Host "Errors:" -ForegroundColor Yellow
        $errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    }
    if ($flutterErrors) {
        Write-Host "Flutter errors:" -ForegroundColor Yellow
        $flutterErrors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    }
} else {
    Write-Host "No errors found in logs!" -ForegroundColor Green
}

# Check import success indicators
Write-Host ""
Write-Host "=== Checking import success ===" -ForegroundColor Cyan
$successLogs = $logs | Select-String -Pattern "import|Import|success|Success" -CaseSensitive:$false
if ($successLogs) {
    Write-Host "Import-related logs found:" -ForegroundColor Green
    $successLogs | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}

# Save full log for analysis
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "C:\flutter_projects\bary3\scripts\import_log_$timestamp.txt"
$logs | Out-File $logFile -Encoding UTF8
Write-Host ""
Write-Host "Full log saved to: $logFile" -ForegroundColor Cyan

# Verify data was imported by checking app data
Write-Host ""
Write-Host "=== Verifying imported data ===" -ForegroundColor Cyan
Write-Host "Checking SharedPreferences..." -ForegroundColor Yellow

# Try to read SharedPreferences (requires root or debug build)
$prefsCheck = & $adb shell run-as $packageName cat /data/data/$packageName/shared_prefs/*.xml 2>&1
if ($prefsCheck -notmatch "Permission denied") {
    $transactionsCount = ($prefsCheck | Select-String -Pattern "transaction" -AllMatches).Matches.Count
    $piggyCount = ($prefsCheck | Select-String -Pattern "piggy" -AllMatches).Matches.Count
    $color1 = if ($transactionsCount -gt 0) { "Green" } else { "Yellow" }
    $color2 = if ($piggyCount -gt 0) { "Green" } else { "Yellow" }
    Write-Host "Found $transactionsCount transaction references" -ForegroundColor $color1
    Write-Host "Found $piggyCount piggy bank references" -ForegroundColor $color2
} else {
    Write-Host "Cannot access SharedPreferences (requires debug build or root)" -ForegroundColor Yellow
    Write-Host "Please verify manually in the app:" -ForegroundColor Yellow
    Write-Host "  - Check Balance screen for transactions" -ForegroundColor White
    Write-Host "  - Check Piggy Banks screen for 3 banks" -ForegroundColor White
    Write-Host "  - Check Calendar for 4 events" -ForegroundColor White
    Write-Host "  - Check Lessons for 5 completed lessons" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($errors) {
    Write-Host "Status: ERRORS DETECTED - Check log file" -ForegroundColor Red
} else {
    Write-Host "Status: No errors detected" -ForegroundColor Green
}
Write-Host "Log file: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Import process completed!" -ForegroundColor Green
