# Fully automated UI import
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$centerX = 640

function Tap { param($x, $y) & $adb shell input tap $x $y; Start-Sleep -Milliseconds 1200 }
function Swipe { param($x1, $y1, $x2, $y2) & $adb shell input swipe $x1 $y1 $x2 $y2 500; Start-Sleep -Milliseconds 600 }

Write-Host "=== Automated Import via UI ===" -ForegroundColor Cyan

# Go to Settings (last tab, bottom right)
Write-Host "Opening Settings..." -ForegroundColor Yellow
Tap 1200 2700
Start-Sleep -Seconds 2

# Scroll down to find Test Data Generator
Write-Host "Scrolling to Test Data Generator..." -ForegroundColor Yellow
for ($i = 0; $i -lt 5; $i++) {
    Swipe $centerX 2000 $centerX 1000
}

# Find and click Test Data Generator (in Export/Import section)
Write-Host "Clicking Test Data Generator..." -ForegroundColor Yellow
Tap $centerX 1400
Start-Sleep -Seconds 2

# Click "Create Weekly Data" button
Write-Host "Clicking Create Weekly Data button..." -ForegroundColor Yellow
Tap $centerX 1200
Start-Sleep -Seconds 5

# Check for success
Write-Host "Checking results..." -ForegroundColor Yellow
$logs = & $adb logcat -d -s flutter:* | Select-Object -Last 20
$success = $logs | Select-String -Pattern "успешно|success|Создано|created" -CaseSensitive:$false
$errors = $logs | Select-String -Pattern "Error|Exception" -CaseSensitive:$false

Write-Host ""
if ($success) {
    Write-Host "SUCCESS: Data imported!" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
} else {
    Write-Host "Status unclear - checking for errors..." -ForegroundColor Yellow
}

if ($errors) {
    Write-Host "Errors:" -ForegroundColor Red
    $errors | Select-Object -First 3 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Import process completed!" -ForegroundColor Cyan
