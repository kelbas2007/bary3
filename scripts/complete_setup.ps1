# Полная настройка для запуска GitHub Actions workflow

Write-Host "=== Complete GitHub Actions Setup ===" -ForegroundColor Green
Write-Host ""

# 1. Инициализация git (если нужно)
if (-not (Test-Path .git)) {
    Write-Host "Initializing git repository..." -ForegroundColor Cyan
    git init
    git add .github/workflows/build_llama.yml scripts/build_llama_*.sh
    git commit -m "Add GitHub Actions workflow for llama.cpp compilation"
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "✅ Git repository exists" -ForegroundColor Green
}

# 2. Проверка GitHub CLI
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$gh = Get-Command gh -ErrorAction SilentlyContinue

if (-not $gh) {
    Write-Host "ERROR: GitHub CLI not found" -ForegroundColor Red
    Write-Host "Please restart PowerShell after installing GitHub CLI" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ GitHub CLI found" -ForegroundColor Green

# 3. Проверка авторизации
Write-Host ""
Write-Host "Checking GitHub authentication..." -ForegroundColor Cyan
$authCheck = gh auth status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Not authenticated" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please authenticate:" -ForegroundColor Cyan
    Write-Host "  1. A browser window will open" -ForegroundColor White
    Write-Host "  2. Authorize GitHub CLI" -ForegroundColor White
    Write-Host "  3. Return here" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "Press Enter to start authentication (or 'skip' to do it manually)"
    if ($response -ne "skip") {
        gh auth login --web
    } else {
        Write-Host "Skipping authentication. Please run 'gh auth login' manually" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ Authenticated" -ForegroundColor Green
}

# 4. Создание GitHub репозитория (если нужно)
Write-Host ""
Write-Host "Checking GitHub remote..." -ForegroundColor Cyan
$remote = git config --get remote.origin.url 2>$null

if (-not $remote) {
    Write-Host "No GitHub remote found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To create GitHub repository:" -ForegroundColor Cyan
    Write-Host "  gh repo create bary3 --public --source=. --remote=origin --push" -ForegroundColor White
    Write-Host ""
    
    $create = Read-Host "Create GitHub repository now? (y/N)"
    if ($create -eq "y" -or $create -eq "Y") {
        Write-Host "Creating GitHub repository..." -ForegroundColor Cyan
        gh repo create bary3 --public --source=. --remote=origin --push
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Repository created and pushed" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Failed to create repository automatically" -ForegroundColor Yellow
            Write-Host "Please create it manually and push code" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "✅ GitHub remote found: $remote" -ForegroundColor Green
}

# 5. Запуск workflow
Write-Host ""
Write-Host "Ready to trigger workflow!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Ensure code is pushed to GitHub" -ForegroundColor White
Write-Host "  2. Run: .\scripts\trigger_github_actions.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Or trigger manually:" -ForegroundColor Yellow
Write-Host "  1. Open GitHub repository in browser" -ForegroundColor White
Write-Host "  2. Go to Actions tab" -ForegroundColor White
Write-Host "  3. Click 'Run workflow'" -ForegroundColor White
