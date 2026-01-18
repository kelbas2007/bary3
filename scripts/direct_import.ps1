# Direct import using the test data generator in the app
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$packageName = "com.bary3.app"

Write-Host "=== Direct Automated Import ===" -ForegroundColor Cyan
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
& $adb logcat -c

# Start app
Write-Host "Starting app..." -ForegroundColor Yellow
& $adb shell am start -n $packageName/com.example.bary3.MainActivity
Start-Sleep -Seconds 3

# Screen coordinates
$centerX = 640
$tabSettings = @{x = 1200; y = 2700}

function Tap-Screen {
    param($x, $y)
    & $adb shell input tap $x $y
    Start-Sleep -Milliseconds 1000
}

function Swipe-Screen {
    param($x1, $y1, $x2, $y2)
    & $adb shell input swipe $x1 $y1 $x2 $y2 500
    Start-Sleep -Milliseconds 500
}

Write-Host "Navigating to Settings..." -ForegroundColor Yellow
Tap-Screen $tabSettings.x $tabSettings.y
Start-Sleep -Seconds 2

Write-Host "Scrolling to find Test Data Generator..." -ForegroundColor Yellow
# Scroll down to find the test data generator (it's in Export/Import section)
for ($i = 0; $i -lt 4; $i++) {
    Swipe-Screen $centerX 2000 $centerX 1000 500
    Start-Sleep -Milliseconds 500
}

Write-Host "Looking for Test Data Generator button..." -ForegroundColor Yellow
# Try to find the test data generator button (it should be visible after scrolling)
# It's in the Export/Import section, approximately at y=1400-1600
Tap-Screen $centerX 1500
Start-Sleep -Seconds 2

Write-Host "Clicking 'Create Weekly Data' button..." -ForegroundColor Yellow
# The button should be visible now - click it
Tap-Screen $centerX 1200
Start-Sleep -Seconds 3

Write-Host "Waiting for data generation..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "=== Checking Results ===" -ForegroundColor Cyan

# Check logs for success/errors
$logs = & $adb logcat -d -s flutter:* | Select-Object -Last 30
$success = $logs | Select-String -Pattern "успешно|success|created|Создано" -CaseSensitive:$false
$errors = $logs | Select-String -Pattern "Error|Exception|Failed" -CaseSensitive:$false

if ($success) {
    Write-Host "Success messages found:" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}

if ($errors) {
    Write-Host "Errors found:" -ForegroundColor Red
    $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors found" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan
Write-Host "Data should be imported. Please verify in the app:" -ForegroundColor Yellow
Write-Host "  - Balance: 13 transactions" -ForegroundColor White
Write-Host "  - Piggy Banks: 3 banks" -ForegroundColor White
Write-Host "  - Calendar: 4 events" -ForegroundColor White
Write-Host "  - Lessons: 5 completed" -ForegroundColor White
Write-Host ""

if ($success -and -not $errors) {
    Write-Host "Status: SUCCESS - Data imported!" -ForegroundColor Green
} else {
    Write-Host "Status: Please check manually" -ForegroundColor Yellow
}

Write-Host ""
