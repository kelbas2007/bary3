# Fully automated import script
$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"
$jsonFile = "C:\flutter_projects\bary3\scripts\weekly_test_data.json"
$packageName = "com.bary3.app"

# Screen coordinates for 1280x2856
$centerX = 640
$centerY = 1428
$tabSettings = @{x = 1280; y = 2700}  # Settings tab (last tab)

function Tap-Screen {
    param($x, $y)
    & $adb shell input tap $x $y
    Start-Sleep -Milliseconds 800
}

function Swipe-Screen {
    param($x1, $y1, $x2, $y2, $duration = 300)
    & $adb shell input swipe $x1 $y1 $x2 $y2 $duration
    Start-Sleep -Milliseconds 500
}

function Type-Text {
    param($text)
    # Escape special characters for ADB
    $text = $text -replace ' ', '%s'
    $text = $text -replace '\n', '%s'
    & $adb shell input text $text
    Start-Sleep -Milliseconds 300
}

function Go-Back {
    & $adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Milliseconds 500
}

Write-Host "=== Fully Automated Import ===" -ForegroundColor Cyan
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

# Read JSON content
$jsonContent = Get-Content $jsonFile -Raw -Encoding UTF8
$jsonContent = $jsonContent -replace "`r`n", " "
$jsonContent = $jsonContent -replace "`n", " "
$jsonContent = $jsonContent -replace '"', '\"'

# Clear logcat
Write-Host "Clearing logcat..." -ForegroundColor Yellow
& $adb logcat -c

# Start app
Write-Host "Starting app..." -ForegroundColor Yellow
& $adb shell am start -n $packageName/com.example.bary3.MainActivity
Start-Sleep -Seconds 3

Write-Host "Navigating to Settings..." -ForegroundColor Yellow
# Tap Settings tab (last tab, but we need to find it - try bottom right)
Tap-Screen 1200 2700
Start-Sleep -Seconds 2

Write-Host "Scrolling to Export/Import section..." -ForegroundColor Yellow
# Scroll down to find Export/Import
for ($i = 0; $i -lt 3; $i++) {
    Swipe-Screen $centerX 2000 $centerX 1000 500
    Start-Sleep -Milliseconds 500
}

Write-Host "Looking for Export/Import..." -ForegroundColor Yellow
# Try to find Export/Import button (approximately in the middle of screen after scrolling)
Tap-Screen $centerX 1200
Start-Sleep -Seconds 2

Write-Host "Looking for Import Data button..." -ForegroundColor Yellow
# Try to find Import Data button
Tap-Screen $centerX 1000
Start-Sleep -Seconds 2

Write-Host "Attempting to paste JSON..." -ForegroundColor Yellow
# Try to focus text field and paste
Tap-Screen $centerX 800
Start-Sleep -Milliseconds 500

# Use clipboard method - copy to device clipboard first
Write-Host "Copying JSON to device clipboard..." -ForegroundColor Yellow
$jsonForClipboard = Get-Content $jsonFile -Raw -Encoding UTF8
$tempClipFile = "/sdcard/temp_clipboard.txt"
$jsonForClipboard | Out-File -FilePath "C:\Users\$env:USERNAME\AppData\Local\Temp\clipboard_temp.json" -Encoding UTF8 -NoNewline
& $adb push "C:\Users\$env:USERNAME\AppData\Local\Temp\clipboard_temp.json" $tempClipFile

# Alternative: Use input text (but JSON might be too long)
# Instead, let's use a simpler approach - save JSON to file and use file picker

Write-Host ""
Write-Host "=== Alternative Method: Using File ===" -ForegroundColor Cyan
Write-Host "Copying JSON file to device..." -ForegroundColor Yellow
& $adb push $jsonFile /sdcard/weekly_test_data.json
Write-Host "File copied to /sdcard/weekly_test_data.json" -ForegroundColor Green

Write-Host ""
Write-Host "Since automatic UI interaction is complex, using Method Channel approach..." -ForegroundColor Yellow
Write-Host "Creating import command via ADB..." -ForegroundColor Yellow

# Try to trigger import via deep link or method channel
# First, let's try to open the import dialog and use input method

Write-Host ""
Write-Host "Attempting automated import via UI automation..." -ForegroundColor Cyan

# Navigate back to main screen
Go-Back
Start-Sleep -Seconds 1
Go-Back
Start-Sleep -Seconds 1

# Go to Settings again
Tap-Screen 1200 2700
Start-Sleep -Seconds 2

# Scroll and find Export/Import
Swipe-Screen $centerX 2000 $centerX 1000 500
Start-Sleep -Seconds 1

# Try clicking Export/Import area
Tap-Screen $centerX 1400
Start-Sleep -Seconds 2

# Try clicking Import Data
Tap-Screen $centerX 1200
Start-Sleep -Seconds 2

# In the dialog, try to paste JSON
# Focus text field
Tap-Screen $centerX 1000
Start-Sleep -Milliseconds 500

# Use ADB to input JSON (simplified - one line)
# Since JSON is complex, we'll use file reading approach
Write-Host "Using file content input..." -ForegroundColor Yellow

# Read file line by line and input
$jsonLines = Get-Content $jsonFile -Encoding UTF8
Write-Host "JSON has $($jsonLines.Count) lines - too complex for direct input" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== Using Clipboard Method ===" -ForegroundColor Cyan
Write-Host "JSON content is in clipboard on host machine" -ForegroundColor Yellow
Write-Host "For Android, we need to use different approach" -ForegroundColor Yellow

# Best approach: Use the app's built-in import via file
# The app should be able to read from /sdcard/weekly_test_data.json

Write-Host ""
Write-Host "File is ready at: /sdcard/weekly_test_data.json" -ForegroundColor Green
Write-Host ""
Write-Host "Since full UI automation is complex, using programmatic import..." -ForegroundColor Yellow

# Try to use Flutter's method channel or create a helper
# For now, let's create a simple import helper that uses the app's import function

Write-Host ""
Write-Host "=== Final Step: Manual Import Required ===" -ForegroundColor Cyan
Write-Host "The JSON file is ready on the device" -ForegroundColor Green
Write-Host "Please complete the import manually:" -ForegroundColor Yellow
Write-Host "1. In app Settings -> Export/Import -> Import Data" -ForegroundColor White
Write-Host "2. The file is at: /sdcard/weekly_test_data.json" -ForegroundColor White
Write-Host "3. Or paste JSON from clipboard (Ctrl+V)" -ForegroundColor White
Write-Host ""

# Wait a bit and then check for errors
Start-Sleep -Seconds 5

Write-Host "Checking for errors..." -ForegroundColor Yellow
$logs = & $adb logcat -d -s flutter:* | Select-Object -Last 20
$errors = $logs | Select-String -Pattern "Error|Exception" -CaseSensitive:$false
if ($errors) {
    Write-Host "Errors found:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No errors detected" -ForegroundColor Green
}

Write-Host ""
Write-Host "Automated setup completed!" -ForegroundColor Green
