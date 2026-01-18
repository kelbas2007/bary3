# Запуск workflow с использованием токена напрямую
# Используйте этот скрипт если авторизация была в другой сессии

param(
    [string]$GitHubToken
)

Write-Host "=== Triggering GitHub Actions with Token ===" -ForegroundColor Green
Write-Host ""

# Получаем токен
if (-not $GitHubToken) {
    # Пробуем получить из переменной окружения
    $GitHubToken = $env:GH_TOKEN
    
    if (-not $GitHubToken) {
        # Пробуем получить через gh auth token
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        $GitHubToken = gh auth token 2>&1
        
        if ($GitHubToken -match "error" -or $GitHubToken.Length -lt 20) {
            Write-Host "Please provide GitHub token:" -ForegroundColor Yellow
            Write-Host "  1. Get token: gh auth token (in the session where you authenticated)" -ForegroundColor White
            Write-Host "  2. Run: `$env:GH_TOKEN = 'your_token'; .\scripts\trigger_with_token.ps1" -ForegroundColor White
            Write-Host ""
            Write-Host "Or provide as parameter:" -ForegroundColor Yellow
            Write-Host "  .\scripts\trigger_with_token.ps1 -GitHubToken 'your_token'" -ForegroundColor White
            exit 1
        }
    }
}

Write-Host "✅ Token obtained" -ForegroundColor Green

# Получаем информацию о репозитории
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Пробуем получить через API
$headers = @{
    "Authorization" = "Bearer $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}

Write-Host "Getting repository information..." -ForegroundColor Cyan
$user = (Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers).login
Write-Host "GitHub user: $user" -ForegroundColor Green

# Проверяем, существует ли репозиторий
$repoName = "bary3"
$repoUrl = "https://api.github.com/repos/$user/$repoName"

try {
    $repo = Invoke-RestMethod -Uri $repoUrl -Headers $headers -Method Get
    Write-Host "✅ Repository exists: $user/$repoName" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "Repository not found, creating..." -ForegroundColor Yellow
        
        $createBody = @{
            name = $repoName
            description = "Bary3 - Financial education app for kids"
            private = $false
        } | ConvertTo-Json
        
        try {
            $repo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $createBody -ContentType "application/json"
            Write-Host "✅ Repository created" -ForegroundColor Green
            
            # Добавляем remote и пушим
            git remote add origin "https://github.com/$user/$repoName.git" 2>$null
            git remote set-url origin "https://github.com/$user/$repoName.git" 2>$null
            git push -u origin master 2>&1
        } catch {
            Write-Host "ERROR: Could not create repository" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "ERROR: Could not access repository" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# Убеждаемся, что код запушен
Write-Host ""
Write-Host "Ensuring code is pushed..." -ForegroundColor Cyan
git push -u origin master 2>&1 | Out-Null

# Получаем workflow ID
Write-Host "Finding workflow..." -ForegroundColor Cyan
$workflowsUrl = "https://api.github.com/repos/$user/$repoName/actions/workflows"

try {
    $workflows = Invoke-RestMethod -Uri $workflowsUrl -Headers $headers -Method Get
    $workflow = $workflows.workflows | Where-Object { $_.name -eq "Build llama.cpp for AKA" -or $_.path -eq ".github/workflows/build_llama.yml" } | Select-Object -First 1
    
    if (-not $workflow) {
        Write-Host "ERROR: Workflow not found" -ForegroundColor Red
        Write-Host "Available workflows:" -ForegroundColor Yellow
        $workflows.workflows | ForEach-Object { Write-Host "  - $($_.name) ($($_.path))" -ForegroundColor White }
        exit 1
    }
    
    $workflowId = $workflow.id
    Write-Host "✅ Workflow found: $($workflow.name) (ID: $workflowId)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Could not get workflows" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Запускаем workflow
Write-Host ""
Write-Host "Triggering workflow..." -ForegroundColor Yellow
$triggerUrl = "https://api.github.com/repos/$user/$repoName/actions/workflows/$workflowId/dispatches"

$body = @{
    ref = "master"  # или "main" в зависимости от вашей ветки
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $triggerUrl -Headers $headers -Method Post -Body $body -ContentType "application/json"
    
    Write-Host ""
    Write-Host "✅ Workflow triggered successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "View progress:" -ForegroundColor Cyan
    Write-Host "  https://github.com/$user/$repoName/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "The workflow will run in the background (~15-20 minutes)" -ForegroundColor Yellow
    Write-Host "Check back later for artifacts!" -ForegroundColor Yellow
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to trigger workflow" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host ""
        Write-Host "Possible issues:" -ForegroundColor Yellow
        Write-Host "  - Workflow file not found or not pushed" -ForegroundColor White
        Write-Host "  - Token doesn't have workflow permissions" -ForegroundColor White
    }
    exit 1
}
