# ФИНАЛЬНЫЙ СКРИПТ ДЛЯ ЗАПУСКА WORKFLOW
# Запустите этот скрипт в той же PowerShell сессии, где вы выполнили 'gh auth login'

Write-Host "=== FINAL: Triggering GitHub Actions Workflow ===" -ForegroundColor Green
Write-Host ""

# Обновляем PATH
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Проверка авторизации
Write-Host "1. Checking authentication..." -ForegroundColor Cyan
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated. Please run: gh auth login" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Authenticated" -ForegroundColor Green

# Проверка репозитория
Write-Host ""
Write-Host "2. Checking repository..." -ForegroundColor Cyan
$remote = git config --get remote.origin.url 2>$null

if (-not $remote) {
    Write-Host "Creating GitHub repository..." -ForegroundColor Yellow
    gh repo create bary3 --public --source=. --remote=origin --push
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Could not create repository" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Repository created" -ForegroundColor Green
} else {
    Write-Host "✅ Repository found: $remote" -ForegroundColor Green
    Write-Host "Pushing latest changes..." -ForegroundColor Cyan
    git push -u origin master 2>&1 | Out-Null
}

# Находим workflow
Write-Host ""
Write-Host "3. Finding workflow..." -ForegroundColor Cyan
$workflowId = gh workflow list --json name,id --jq '.[] | select(.name == "Build llama.cpp for AKA") | .id'

if (-not $workflowId) {
    Write-Host "ERROR: Workflow not found" -ForegroundColor Red
    Write-Host "Available workflows:" -ForegroundColor Yellow
    gh workflow list
    exit 1
}

Write-Host "✅ Workflow found: $workflowId" -ForegroundColor Green

# Запускаем workflow
Write-Host ""
Write-Host "4. Triggering workflow..." -ForegroundColor Yellow
gh workflow run $workflowId

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "✅ WORKFLOW TRIGGERED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    
    $repo = gh repo view --json nameWithOwner -q .nameWithOwner
    Write-Host "View progress:" -ForegroundColor Cyan
    Write-Host "  https://github.com/$repo/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "The workflow will run in the background (~15-20 minutes)" -ForegroundColor Yellow
    Write-Host "Check back later to download artifacts!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To watch progress:" -ForegroundColor Cyan
    Write-Host "  gh run list --workflow=$workflowId" -ForegroundColor White
    Write-Host "  gh run watch" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to trigger workflow" -ForegroundColor Red
    exit 1
}
