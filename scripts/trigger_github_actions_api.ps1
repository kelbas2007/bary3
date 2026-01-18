# Скрипт для запуска GitHub Actions workflow через GitHub API
# 
# Требования:
# - GitHub Personal Access Token (PAT) с правами workflow
# - Git репозиторий с GitHub remote

param(
    [string]$GitHubToken,
    [string]$RepoOwner,
    [string]$RepoName,
    [string]$WorkflowFile = "build_llama.yml"
)

Write-Host "=== Triggering GitHub Actions via API ===" -ForegroundColor Green
Write-Host ""

# Получаем информацию о репозитории
if (-not $RepoOwner -or -not $RepoName) {
    $remoteUrl = git config --get remote.origin.url 2>$null
    if ($remoteUrl) {
        if ($remoteUrl -match 'github\.com[:/]([^/]+)/([^/\.]+)') {
            $RepoOwner = $matches[1]
            $RepoName = $matches[2] -replace '\.git$', ''
            Write-Host "Detected repository: $RepoOwner/$RepoName" -ForegroundColor Cyan
        }
    }
}

if (-not $RepoOwner -or -not $RepoName) {
    Write-Host "ERROR: Could not determine repository" -ForegroundColor Red
    Write-Host "Please provide -RepoOwner and -RepoName parameters" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  .\scripts\trigger_github_actions_api.ps1 -GitHubToken <token> -RepoOwner <owner> -RepoName <repo>" -ForegroundColor White
    exit 1
}

# Получаем токен
if (-not $GitHubToken) {
    $GitHubToken = $env:GITHUB_TOKEN
}

if (-not $GitHubToken) {
    Write-Host "ERROR: GitHub token not provided" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide a GitHub Personal Access Token:" -ForegroundColor Yellow
    Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "  2. Generate new token (classic)" -ForegroundColor White
    Write-Host "  3. Select scope: 'workflow'" -ForegroundColor White
    Write-Host "  4. Use it as:" -ForegroundColor White
    Write-Host "     `$env:GITHUB_TOKEN = 'your_token'" -ForegroundColor Gray
    Write-Host "     .\scripts\trigger_github_actions_api.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or provide as parameter:" -ForegroundColor Yellow
    Write-Host "  .\scripts\trigger_github_actions_api.ps1 -GitHubToken <token>" -ForegroundColor White
    exit 1
}

Write-Host "Repository: $RepoOwner/$RepoName" -ForegroundColor Cyan
Write-Host "Workflow file: $WorkflowFile" -ForegroundColor Cyan
Write-Host ""

# Получаем workflow ID
Write-Host "Getting workflow ID..." -ForegroundColor Cyan
$workflowUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/workflows/$WorkflowFile"

$headers = @{
    "Authorization" = "Bearer $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}

try {
    $workflow = Invoke-RestMethod -Uri $workflowUrl -Headers $headers -Method Get
    $workflowId = $workflow.id
    
    Write-Host "Workflow ID: $workflowId" -ForegroundColor Green
    Write-Host "Workflow name: $($workflow.name)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Could not get workflow information" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Запускаем workflow
Write-Host "Triggering workflow..." -ForegroundColor Yellow
$triggerUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/workflows/$workflowId/dispatches"

$body = @{
    ref = "main"  # или "master" в зависимости от вашей основной ветки
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $triggerUrl -Headers $headers -Method Post -Body $body -ContentType "application/json"
    
    Write-Host ""
    Write-Host "✅ Workflow triggered successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "View progress:" -ForegroundColor Cyan
    Write-Host "  https://github.com/$RepoOwner/$RepoName/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "The workflow will run in the background." -ForegroundColor Yellow
    Write-Host "Check back in 15-20 minutes for artifacts." -ForegroundColor Yellow
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to trigger workflow" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host ""
        Write-Host "Possible issues:" -ForegroundColor Yellow
        Write-Host "  - Workflow file not found: $WorkflowFile" -ForegroundColor White
        Write-Host "  - Repository name incorrect" -ForegroundColor White
        Write-Host "  - Token doesn't have workflow permissions" -ForegroundColor White
    }
    exit 1
}
