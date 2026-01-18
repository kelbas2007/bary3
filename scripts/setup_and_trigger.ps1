# Полный скрипт для настройки и запуска GitHub Actions workflow

Write-Host "=== Setup and Trigger GitHub Actions ===" -ForegroundColor Green
Write-Host ""

# Проверка git репозитория
if (-not (Test-Path .git)) {
    Write-Host "WARNING: Not a git repository" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To use GitHub Actions, you need:" -ForegroundColor Cyan
    Write-Host "  1. Initialize git repository:" -ForegroundColor White
    Write-Host "     git init" -ForegroundColor Gray
    Write-Host "     git add ." -ForegroundColor Gray
    Write-Host "     git commit -m 'Initial commit'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Create GitHub repository and push:" -ForegroundColor White
    Write-Host "     gh repo create <repo-name> --public --source=. --remote=origin --push" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or use manual trigger:" -ForegroundColor Yellow
    Write-Host "  1. Create GitHub repository manually" -ForegroundColor White
    Write-Host "  2. Push code to GitHub" -ForegroundColor White
    Write-Host "  3. Go to Actions tab and click 'Run workflow'" -ForegroundColor White
    exit 1
}

Write-Host "Git repository found" -ForegroundColor Green

# Проверка GitHub CLI
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$gh = Get-Command gh -ErrorAction SilentlyContinue

if (-not $gh) {
    Write-Host "GitHub CLI not found in PATH" -ForegroundColor Yellow
    Write-Host "Trying to find in common locations..." -ForegroundColor Cyan
    
    $commonPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GitHub.cli_Microsoft.Winget.Source_*\gh.exe",
        "$env:ProgramFiles\GitHub CLI\gh.exe"
    )
    
    $found = $false
    foreach ($path in $commonPaths) {
        $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
        if ($resolved) {
            $env:PATH += ";$($resolved.Directory)"
            $found = $true
            Write-Host "Found GitHub CLI: $resolved" -ForegroundColor Green
            break
        }
    }
    
    if (-not $found) {
        Write-Host "ERROR: GitHub CLI not found" -ForegroundColor Red
        Write-Host "Please restart PowerShell or add GitHub CLI to PATH" -ForegroundColor Yellow
        exit 1
    }
}

# Проверка авторизации
Write-Host "Checking GitHub authentication..." -ForegroundColor Cyan
$authStatus = gh auth status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Not authenticated with GitHub CLI" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Starting authentication..." -ForegroundColor Cyan
    gh auth login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Authentication failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Authenticated" -ForegroundColor Green
}

# Получаем информацию о репозитории
Write-Host ""
Write-Host "Getting repository information..." -ForegroundColor Cyan
$repo = gh repo view --json nameWithOwner -q .nameWithOwner 2>$null

if (-not $repo) {
    Write-Host "ERROR: Could not determine repository" -ForegroundColor Red
    Write-Host "Please ensure you're in a git repository with GitHub remote" -ForegroundColor Yellow
    exit 1
}

Write-Host "Repository: $repo" -ForegroundColor Green

# Находим workflow
Write-Host ""
Write-Host "Finding workflow..." -ForegroundColor Cyan
$workflowId = gh workflow list --json name,id --jq '.[] | select(.name == "Build llama.cpp for AKA") | .id' 2>$null

if (-not $workflowId) {
    Write-Host "WARNING: Workflow 'Build llama.cpp for AKA' not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Available workflows:" -ForegroundColor Cyan
    gh workflow list
    Write-Host ""
    Write-Host "Please ensure workflow file exists: .github/workflows/build_llama.yml" -ForegroundColor Yellow
    exit 1
}

Write-Host "Workflow ID: $workflowId" -ForegroundColor Green

# Запускаем workflow
Write-Host ""
Write-Host "Triggering workflow..." -ForegroundColor Yellow
gh workflow run $workflowId

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Workflow triggered successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "View progress:" -ForegroundColor Cyan
    Write-Host "  gh run list --workflow=$workflowId" -ForegroundColor White
    Write-Host "  gh run watch" -ForegroundColor White
    Write-Host ""
    Write-Host "Or open in browser:" -ForegroundColor Cyan
    Write-Host "  https://github.com/$repo/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "The workflow will run in the background (~15-20 minutes)" -ForegroundColor Yellow
    Write-Host "Check back later for artifacts!" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to trigger workflow" -ForegroundColor Red
    exit 1
}
