# Complete automated import - Version 2
# Uses UI automation to click the test data generator button

$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$packageName = "com.bary3.app"
$centerX = 640

function Tap { param($x, $y) & $adb shell input tap $x $y; Start-Sleep -Milliseconds 1500 }
function Swipe { param($x1, $y1, $x2, $y2) & $adb shell input swipe $x1 $y1 $x2 $y2 500; Start-Sleep -Milliseconds 800 }

Write-Host "=== Complete Automated Import V2 ===" -ForegroundColor Cyan
Write-Host ""

# Check emulator
$devices = & $adb devices 2>&1
$deviceConnected = $devices | Select-String -Pattern "device$"
if (-not $deviceConnected) {
    Write-Host "ERROR: Emulator not connected!" -ForegroundColor Red
    exit 1
}
Write-Host "Emulator connected" -ForegroundColor Green

# Clear logs
& $adb logcat -c

# Force stop and restart app
Write-Host "Restarting app..." -ForegroundColor Yellow
& $adb shell am force-stop $packageName
Start-Sleep -Seconds 2
& $adb shell am start -n $packageName/com.example.bary3.MainActivity
Start-Sleep -Seconds 4

Write-Host "Navigating to Settings..." -ForegroundColor Yellow
# Tap Settings tab (last tab, try different positions)
Tap 1200 2700
Start-Sleep -Seconds 2

Write-Host "Scrolling to find Test Data Generator..." -ForegroundColor Yellow
# Scroll down multiple times to find the test data generator
for ($i = 0; $i -lt 6; $i++) {
    Swipe $centerX 2200 $centerX 800
}

Write-Host "Looking for Test Data Generator button..." -ForegroundColor Yellow
# Try multiple positions where the button might be
$positions = @(
    @{x = $centerX; y = 1600},
    @{x = $centerX; y = 1400},
    @{x = $centerX; y = 1500},
    @{x = $centerX; y = 1300}
)

foreach ($pos in $positions) {
    Write-Host "Trying position ($($pos.x), $($pos.y))..." -ForegroundColor Gray
    Tap $pos.x $pos.y
    Start-Sleep -Seconds 2
    
    # Check if we're in the test data screen (look for the create button)
    # The button should be around y=1200-1400
    Write-Host "Looking for Create Weekly Data button..." -ForegroundColor Gray
    Tap $centerX 1300
    Start-Sleep -Seconds 3
    
    # Check logs for success
    $logs = & $adb logcat -d -s flutter:* | Select-Object -Last 10
    $found = $logs | Select-String -Pattern "Тестовые|успешно|Создано|generateWeekly" -CaseSensitive:$false
    if ($found) {
        Write-Host "SUCCESS! Data generation detected!" -ForegroundColor Green
        break
    }
    
    # Go back and try next position
    & $adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "Waiting for import to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "=== Final Check ===" -ForegroundColor Cyan
$finalLogs = & $adb logcat -d -s flutter:* | Select-Object -Last 30
$success = $finalLogs | Select-String -Pattern "успешно|success|Создано|created|импортированы" -CaseSensitive:$false
$dataGen = $finalLogs | Select-String -Pattern "транзакц|копилк|событи|урок|Transaction|Piggy|Event" -CaseSensitive:$false
$errors = $finalLogs | Select-String -Pattern "Error|Exception" -CaseSensitive:$false

if ($success) {
    Write-Host "SUCCESS messages found:" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}

if ($dataGen) {
    Write-Host "Data generation messages: $($dataGen.Count)" -ForegroundColor Green
}

if ($errors) {
    Write-Host "Errors:" -ForegroundColor Red
    $errors | Select-Object -First 3 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors found" -ForegroundColor Green
}

Write-Host ""
if ($success -or $dataGen) {
    Write-Host "Status: SUCCESS - Data should be imported!" -ForegroundColor Green
} else {
    Write-Host "Status: Please check manually in Settings -> Test Data Generator" -ForegroundColor Yellow
}

Write-Host ""
