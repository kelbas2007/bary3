# Автоматический запуск GitHub Actions workflow
# Работает даже если авторизация в другой сессии

Write-Host "=== Auto-triggering GitHub Actions Workflow ===" -ForegroundColor Green
Write-Host ""

# Обновляем PATH для GitHub CLI
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Проверяем авторизацию
Write-Host "Checking GitHub authentication..." -ForegroundColor Cyan
$authStatus = gh auth status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Not authenticated in this session" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Trying to refresh authentication..." -ForegroundColor Cyan
    
    # Пробуем получить токен из сохраненной конфигурации
    $ghConfig = "$env:USERPROFILE\.config\gh\hosts.yml"
    if (Test-Path $ghConfig) {
        Write-Host "Found GitHub config, trying to use saved token..." -ForegroundColor Cyan
        $token = gh auth token 2>&1
        
        if ($token -and $token -notmatch "error" -and $token.Length -gt 20) {
            $env:GH_TOKEN = $token
            Write-Host "✅ Using saved token" -ForegroundColor Green
        } else {
            Write-Host "❌ Could not retrieve token" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please run in the same PowerShell session where you authenticated:" -ForegroundColor Yellow
            Write-Host "  gh auth login" -ForegroundColor White
            Write-Host "  .\scripts\auto_trigger_workflow.ps1" -ForegroundColor White
            exit 1
        }
    } else {
        Write-Host "❌ GitHub config not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please authenticate first:" -ForegroundColor Yellow
        Write-Host "  gh auth login" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "✅ Authenticated" -ForegroundColor Green
}

# Проверяем наличие репозитория
Write-Host ""
Write-Host "Checking repository..." -ForegroundColor Cyan
$remote = git config --get remote.origin.url 2>$null

if (-not $remote) {
    Write-Host "No remote repository found" -ForegroundColor Yellow
    Write-Host "Creating GitHub repository..." -ForegroundColor Cyan
    
    # Получаем имя пользователя
    $user = gh api user --jq .login 2>$null
    if (-not $user) {
        Write-Host "ERROR: Could not get GitHub username" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Creating repository: $user/bary3" -ForegroundColor Cyan
    gh repo create bary3 --public --source=. --remote=origin --push 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ Repository might already exist or push failed" -ForegroundColor Yellow
        Write-Host "Checking if repository exists..." -ForegroundColor Cyan
        
        # Проверяем, существует ли репозиторий
        $repoExists = gh repo view "$user/bary3" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Repository exists, adding remote..." -ForegroundColor Green
            git remote add origin "https://github.com/$user/bary3.git" 2>$null
            git push -u origin master 2>&1
        } else {
            Write-Host "ERROR: Could not create or access repository" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✅ Repository created and pushed" -ForegroundColor Green
    }
} else {
    Write-Host "✅ Remote repository found: $remote" -ForegroundColor Green
    
    # Убеждаемся, что код запушен
    $branch = git branch --show-current
    Write-Host "Current branch: $branch" -ForegroundColor Cyan
    
    Write-Host "Pushing latest changes..." -ForegroundColor Cyan
    git push -u origin $branch 2>&1
}

# Находим и запускаем workflow
Write-Host ""
Write-Host "Finding workflow..." -ForegroundColor Cyan
$workflowId = gh workflow list --json name,id --jq '.[] | select(.name == "Build llama.cpp for AKA") | .id' 2>&1

if (-not $workflowId -or $workflowId -match "error") {
    Write-Host "⚠️ Workflow not found by name, trying by file..." -ForegroundColor Yellow
    $workflowId = gh workflow list --json name,id,path --jq '.[] | select(.path == ".github/workflows/build_llama.yml") | .id' 2>&1
}

if (-not $workflowId -or $workflowId -match "error") {
    Write-Host "ERROR: Could not find workflow" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available workflows:" -ForegroundColor Yellow
    gh workflow list
    Write-Host ""
    Write-Host "Please ensure .github/workflows/build_llama.yml exists and is pushed" -ForegroundColor Yellow
    exit 1
}

Write-Host "Workflow ID: $workflowId" -ForegroundColor Green

# Запускаем workflow
Write-Host ""
Write-Host "Triggering workflow..." -ForegroundColor Yellow
gh workflow run $workflowId 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Workflow triggered successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Получаем URL репозитория
    $repo = gh repo view --json nameWithOwner -q .nameWithOwner 2>&1
    if ($repo) {
        Write-Host "View progress:" -ForegroundColor Cyan
        Write-Host "  https://github.com/$repo/actions" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "The workflow will run in the background (~15-20 minutes)" -ForegroundColor Yellow
    Write-Host "Check back later for artifacts!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To watch progress:" -ForegroundColor Cyan
    Write-Host "  gh run list --workflow=$workflowId" -ForegroundColor White
    Write-Host "  gh run watch" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to trigger workflow" -ForegroundColor Red
    Write-Host "Please check the error message above" -ForegroundColor Yellow
    exit 1
}
