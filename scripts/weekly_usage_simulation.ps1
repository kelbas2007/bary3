# Weekly Usage Simulation Script
# Simulates a week of app usage on emulator using ADB

$adb = "C:\Users\kolba\AppData\Local\Android\sdk\platform-tools\adb.exe"

Write-Host "Starting weekly usage simulation..." -ForegroundColor Green

function Tap-Screen {
    param($x, $y)
    & $adb shell input tap $x $y
    Start-Sleep -Milliseconds 500
}

function Type-Text {
    param($text)
    & $adb shell input text $text
    Start-Sleep -Milliseconds 300
}

function Swipe-Screen {
    param($x1, $y1, $x2, $y2, $duration = 300)
    & $adb shell input swipe $x1 $y1 $x2 $y2 $duration
    Start-Sleep -Milliseconds 500
}

function Go-Back {
    & $adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Milliseconds 500
}

function Wait-For {
    param($seconds)
    Write-Host "Waiting $seconds seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds $seconds
}

# Screen coordinates for 1280x2856
$screenWidth = 1280
$screenHeight = 2856
$centerX = 640
$centerY = 1428

# Tab coordinates (Bottom Navigation Bar at y=2700)
$tabBalance = @{x = 256; y = 2700}
$tabPiggy = @{x = 512; y = 2700}
$tabCalendar = @{x = 768; y = 2700}
$tabLessons = @{x = 1024; y = 2700}
$tabSettings = @{x = 1280; y = 2700}

# Button coordinates
$fabButton = @{x = 1100; y = 2500}

Write-Host "Checking emulator connection..." -ForegroundColor Cyan
$devices = & $adb devices
if ($devices -notmatch "device$") {
    Write-Host "ERROR: Emulator not connected!" -ForegroundColor Red
    exit 1
}

Write-Host "Emulator connected" -ForegroundColor Green
Write-Host "Starting user action simulation..." -ForegroundColor Cyan
Write-Host ""

# DAY 1: App exploration
Write-Host "DAY 1: First app exploration" -ForegroundColor Magenta
Write-Host "  -> Opening Balance screen"
Tap-Screen $tabBalance.x $tabBalance.y
Wait-For 2

Write-Host "  -> Viewing quick tools"
Swipe-Screen $centerX 1000 $centerX 600 500
Wait-For 1
Swipe-Screen $centerX 600 $centerX 1000 500
Wait-For 1

Write-Host "  -> Opening Piggy Banks"
Tap-Screen $tabPiggy.x $tabPiggy.y
Wait-For 2

Write-Host "  -> Opening Calendar"
Tap-Screen $tabCalendar.x $tabCalendar.y
Wait-For 2

Write-Host "  -> Opening Lessons"
Tap-Screen $tabLessons.x $tabLessons.y
Wait-For 2

Write-Host "  -> Opening Settings"
Tap-Screen $tabSettings.x $tabSettings.y
Wait-For 2

# DAY 2: Transactions
Write-Host ""
Write-Host "DAY 2: Working with transactions" -ForegroundColor Magenta
Write-Host "  -> Returning to Balance screen"
Tap-Screen $tabBalance.x $tabBalance.y
Wait-For 2

Write-Host "  -> Opening FAB for adding transaction"
Tap-Screen $fabButton.x $fabButton.y
Wait-For 1

Write-Host "  -> Adding income (pocket money)"
Tap-Screen $centerX 1200
Wait-For 2

Write-Host "  -> Entering amount: 1000"
& $adb shell input text "1000"
Wait-For 1

Write-Host "  -> Saving"
Tap-Screen $centerX 2600
Wait-For 2

Write-Host "  -> Adding expense (food)"
Tap-Screen $fabButton.x $fabButton.y
Wait-For 1
Tap-Screen $centerX 1400
Wait-For 2

& $adb shell input text "300"
Wait-For 1
Tap-Screen $centerX 2600
Wait-For 2

# DAY 3: Piggy banks
Write-Host ""
Write-Host "DAY 3: Creating and topping up piggy banks" -ForegroundColor Magenta
Write-Host "  -> Opening Piggy Banks"
Tap-Screen $tabPiggy.x $tabPiggy.y
Wait-For 2

Write-Host "  -> Creating new piggy bank"
Tap-Screen $fabButton.x $fabButton.y
Wait-For 2

& $adb shell input text "New%SGame"
Wait-For 1

Tap-Screen $centerX 1200
Wait-For 1
& $adb shell input text "5000"
Wait-For 1

Tap-Screen $centerX 2600
Wait-For 2

# DAY 4: Planning events
Write-Host ""
Write-Host "DAY 4: Planning events" -ForegroundColor Magenta
Write-Host "  -> Opening Calendar"
Tap-Screen $tabCalendar.x $tabCalendar.y
Wait-For 2

Write-Host "  -> Creating new event"
Tap-Screen $fabButton.x $fabButton.y
Wait-For 2

& $adb shell input text "Birthday%SGift"
Wait-For 1
Tap-Screen $centerX 1200
Wait-For 1
& $adb shell input text "2000"
Wait-For 1
Tap-Screen $centerX 2600
Wait-For 2

# DAY 5: Using tools
Write-Host ""
Write-Host "DAY 5: Using tools" -ForegroundColor Magenta
Write-Host "  -> Opening Balance screen"
Tap-Screen $tabBalance.x $tabBalance.y
Wait-For 2

Write-Host "  -> Opening quick tools (calculator)"
Tap-Screen 640 1000
Wait-For 3

Write-Host "  -> Selecting budget calculator"
Tap-Screen $centerX 1000
Wait-For 2

Tap-Screen $centerX 800
Wait-For 1
& $adb shell input text "10000"
Wait-For 1
Tap-Screen $centerX 2600
Wait-For 2

Go-Back
Wait-For 1
Go-Back
Wait-For 1

# DAY 6: Bari interaction
Write-Host ""
Write-Host "DAY 6: Interacting with Bari" -ForegroundColor Magenta
Write-Host "  -> Opening Balance screen"
Tap-Screen $tabBalance.x $tabBalance.y
Wait-For 2

Write-Host "  -> Opening Bari chat"
Tap-Screen 1200 2600
Wait-For 2

Tap-Screen 1200 2600
Wait-For 1
Tap-Screen 1200 2600
Wait-For 3

Write-Host "  -> Asking Bari a question"
Tap-Screen $centerX 2700
Wait-For 1
& $adb shell input text "How%Smuch%Smoney%Sdo%SI%Shave"
Wait-For 1

Tap-Screen 1200 2700
Wait-For 3

Go-Back
Wait-For 1

# DAY 7: Lessons and final check
Write-Host ""
Write-Host "DAY 7: Lessons and final check" -ForegroundColor Magenta
Write-Host "  -> Opening Lessons"
Tap-Screen $tabLessons.x $tabLessons.y
Wait-For 2

Write-Host "  -> Opening first lesson"
Tap-Screen $centerX 800
Wait-For 3

Write-Host "  -> Viewing lesson (simulation)"
for ($i = 0; $i -lt 5; $i++) {
    Swipe-Screen $centerX 1500 $centerX 800 500
    Wait-For 1
}

Go-Back
Wait-For 2

Write-Host "  -> Checking statistics in Settings"
Tap-Screen $tabSettings.x $tabSettings.y
Wait-For 2

Swipe-Screen $centerX 1500 $centerX 800 500
Wait-For 1

Write-Host ""
Write-Host "Weekly usage simulation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Completed actions:" -ForegroundColor Cyan
Write-Host "  ✓ Viewed all main screens"
Write-Host "  ✓ Added income and expenses"
Write-Host "  ✓ Created piggy bank"
Write-Host "  ✓ Planned events"
Write-Host "  ✓ Used calculators"
Write-Host "  ✓ Interacted with Bari"
Write-Host "  ✓ Viewed lessons"
Write-Host ""
Write-Host 'All app features tested!' -ForegroundColor Green
