# Запуск workflow через GitHub API напрямую
# Не требует GitHub CLI авторизации

$repoOwner = "kelbas2007"
$repoName = "bary3"
$workflowFile = "build_llama.yml"

Write-Host "=== Triggering Workflow via GitHub API ===" -ForegroundColor Green
Write-Host ""

# Получаем токен из переменной окружения или запрашиваем
$token = $env:GITHUB_TOKEN

if (-not $token) {
    Write-Host "GitHub token not found in environment" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To get a token:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "  2. Generate new token (classic)" -ForegroundColor White
    Write-Host "  3. Select scope: 'workflow'" -ForegroundColor White
    Write-Host "  4. Copy token and run:" -ForegroundColor White
    Write-Host "     `$env:GITHUB_TOKEN = 'your_token'" -ForegroundColor Gray
    Write-Host "     .\scripts\trigger_via_api.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or provide as parameter:" -ForegroundColor Yellow
    Write-Host "  .\scripts\trigger_via_api.ps1 -Token 'your_token'" -ForegroundColor White
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
}

# Получаем workflow ID
Write-Host "Getting workflow ID..." -ForegroundColor Cyan
$workflowsUrl = "https://api.github.com/repos/$repoOwner/$repoName/actions/workflows"

try {
    $workflows = Invoke-RestMethod -Uri $workflowsUrl -Headers $headers -Method Get
    $workflow = $workflows.workflows | Where-Object { 
        $_.name -eq "Build llama.cpp for AKA" -or 
        $_.path -eq ".github/workflows/build_llama.yml" 
    } | Select-Object -First 1
    
    if (-not $workflow) {
        Write-Host "ERROR: Workflow not found" -ForegroundColor Red
        Write-Host "Available workflows:" -ForegroundColor Yellow
        $workflows.workflows | ForEach-Object { 
            Write-Host "  - $($_.name) ($($_.path))" -ForegroundColor White 
        }
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
$triggerUrl = "https://api.github.com/repos/$repoOwner/$repoName/actions/workflows/$workflowId/dispatches"

$body = @{
    ref = "main"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $triggerUrl -Headers $headers -Method Post -Body $body -ContentType "application/json"
    
    Write-Host ""
    Write-Host "✅✅✅ WORKFLOW TRIGGERED SUCCESSFULLY! ✅✅✅" -ForegroundColor Green
    Write-Host ""
    Write-Host "View progress:" -ForegroundColor Cyan
    Write-Host "  https://github.com/$repoOwner/$repoName/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "The workflow will run in the background (~15-20 minutes)" -ForegroundColor Yellow
    Write-Host "Check back later to download artifacts!" -ForegroundColor Yellow
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
