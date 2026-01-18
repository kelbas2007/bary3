# Script to import weekly test data into the app
# Uses ADB to copy JSON file and trigger import

$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$jsonFile = "C:\flutter_projects\bary3\scripts\weekly_test_data.json"

Write-Host "Importing weekly test data..." -ForegroundColor Green

# Check if file exists
if (-not (Test-Path $jsonFile)) {
    Write-Host "ERROR: JSON file not found at $jsonFile" -ForegroundColor Red
    exit 1
}

# Check emulator connection
$devices = & $adb devices
if ($devices -notmatch "device$") {
    Write-Host "ERROR: Emulator not connected!" -ForegroundColor Red
    exit 1
}

Write-Host "Copying JSON file to device..." -ForegroundColor Cyan
& $adb push $jsonFile /sdcard/weekly_test_data.json

Write-Host ""
Write-Host "To import the data:" -ForegroundColor Yellow
Write-Host "1. Open the app on emulator" -ForegroundColor White
Write-Host "2. Go to Settings" -ForegroundColor White
Write-Host "3. Open Export/Import section" -ForegroundColor White
Write-Host "4. Tap 'Import Data'" -ForegroundColor White
Write-Host "5. Select the file from /sdcard/weekly_test_data.json" -ForegroundColor White
Write-Host ""
Write-Host "Or use the app's import feature directly" -ForegroundColor Cyan

# Alternative: Try to open the import screen via deep link
Write-Host ""
Write-Host "Attempting to open import screen..." -ForegroundColor Cyan
& $adb shell am start -a android.intent.action.VIEW -d "bary3://settings/import" com.bary3.app

Write-Host ""
Write-Host "Data file ready at: /sdcard/weekly_test_data.json" -ForegroundColor Green
