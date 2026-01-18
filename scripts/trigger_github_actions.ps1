# Скрипт для запуска GitHub Actions workflow через GitHub CLI или API

param(
    [string]$WorkflowName = "Build llama.cpp for AKA"
)

Write-Host "=== Triggering GitHub Actions Workflow ===" -ForegroundColor Green
Write-Host ""

# Проверка GitHub CLI
$gh = Get-Command gh -ErrorAction SilentlyContinue

if ($gh) {
    Write-Host "GitHub CLI found, using gh command..." -ForegroundColor Cyan
    
    # Проверка авторизации
    $auth = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Not authenticated with GitHub CLI" -ForegroundColor Red
        Write-Host "Please run: gh auth login" -ForegroundColor Yellow
        exit 1
    }
    
    # Получаем имя репозитория
    $repo = gh repo view --json nameWithOwner -q .nameWithOwner 2>$null
    if (-not $repo) {
        Write-Host "ERROR: Could not determine repository name" -ForegroundColor Red
        Write-Host "Please ensure you're in a git repository with GitHub remote" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Repository: $repo" -ForegroundColor Cyan
    
    # Получаем workflow ID
    Write-Host "Finding workflow: $WorkflowName" -ForegroundColor Cyan
    $workflowId = gh workflow list --json name,id --jq ".[] | select(.name == `"$WorkflowName`") | .id" 2>$null
    
    if (-not $workflowId) {
        Write-Host "ERROR: Workflow '$WorkflowName' not found" -ForegroundColor Red
        Write-Host "Available workflows:" -ForegroundColor Yellow
        gh workflow list
        exit 1
    }
    
    Write-Host "Workflow ID: $workflowId" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Triggering workflow..." -ForegroundColor Yellow
    
    # Запускаем workflow
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
    } else {
        Write-Host ""
        Write-Host "ERROR: Failed to trigger workflow" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "GitHub CLI not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Install GitHub CLI" -ForegroundColor Cyan
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor White
    Write-Host "  Or download from: https://cli.github.com/" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Manual trigger" -ForegroundColor Cyan
    Write-Host "  1. Open GitHub repository in browser" -ForegroundColor White
    Write-Host "  2. Go to Actions tab" -ForegroundColor White
    Write-Host "  3. Find '$WorkflowName' workflow" -ForegroundColor White
    Write-Host "  4. Click 'Run workflow'" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 3: Use GitHub API (requires token)" -ForegroundColor Cyan
    Write-Host "  See: scripts/trigger_github_actions_api.ps1" -ForegroundColor White
}
