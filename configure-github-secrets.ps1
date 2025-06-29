#!/usr/bin/env pwsh
# GitHub Secrets and Variables Configuration Script
# This script automatically configures GitHub repository secrets and variables for the Terraform pipeline

param(
    [Parameter(Mandatory=$true)]
    [string]$AzureClientId,
    
    [Parameter(Mandatory=$true)]
    [string]$AzureTenantId
)

Write-Host "=== GitHub Repository Configuration ===" -ForegroundColor Cyan
Write-Host "Setting up secrets and variables for Terraform deployment pipeline..." -ForegroundColor Yellow
Write-Host ""

# Repository information
$repoOwner = "dmrogers1146"
$repoName = "azure-webapp-iac-storage-privateendpoint-nsg"
$repo = "$repoOwner/$repoName"

Write-Host "Repository: $repo" -ForegroundColor Green
Write-Host "Azure Client ID: $AzureClientId" -ForegroundColor Green
Write-Host "Azure Tenant ID: $AzureTenantId" -ForegroundColor Green
Write-Host ""

# Check if user is authenticated with GitHub CLI
Write-Host "Checking GitHub CLI authentication..." -ForegroundColor Yellow
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub CLI not authenticated. Please run: gh auth login" -ForegroundColor Red
    exit 1
}
Write-Host "✅ GitHub CLI authenticated" -ForegroundColor Green
Write-Host ""

# Set GitHub Secrets
Write-Host "Configuring GitHub Secrets..." -ForegroundColor Yellow

Write-Host "  Setting AZURE_CLIENT_ID..." -ForegroundColor Gray
gh secret set AZURE_CLIENT_ID --body $AzureClientId --repo $repo
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ AZURE_CLIENT_ID configured" -ForegroundColor Green
} else {
    Write-Host "  ❌ Failed to set AZURE_CLIENT_ID" -ForegroundColor Red
    exit 1
}

Write-Host "  Setting AZURE_TENANT_ID..." -ForegroundColor Gray
gh secret set AZURE_TENANT_ID --body $AzureTenantId --repo $repo
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ AZURE_TENANT_ID configured" -ForegroundColor Green
} else {
    Write-Host "  ❌ Failed to set AZURE_TENANT_ID" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Set GitHub Variables
Write-Host "Configuring GitHub Variables..." -ForegroundColor Yellow

Write-Host "  Setting AZURE_SUBSCRIPTION_ID_DEV..." -ForegroundColor Gray
gh variable set AZURE_SUBSCRIPTION_ID_DEV --body "a8912e4d-93c4-4867-ab0d-1095943662fd" --repo $repo
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ AZURE_SUBSCRIPTION_ID_DEV configured" -ForegroundColor Green
} else {
    Write-Host "  ❌ Failed to set AZURE_SUBSCRIPTION_ID_DEV" -ForegroundColor Red
    exit 1
}

Write-Host "  Setting AZURE_SUBSCRIPTION_ID_PROD..." -ForegroundColor Gray
gh variable set AZURE_SUBSCRIPTION_ID_PROD --body "34c068fd-ceb1-4bb7-96c6-00360b36cbcb" --repo $repo
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ AZURE_SUBSCRIPTION_ID_PROD configured" -ForegroundColor Green
} else {
    Write-Host "  ❌ Failed to set AZURE_SUBSCRIPTION_ID_PROD" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Verify configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow

Write-Host "Secrets:" -ForegroundColor Cyan
gh secret list --repo $repo | Where-Object { $_ -match "AZURE_" }

Write-Host ""
Write-Host "Variables:" -ForegroundColor Cyan
gh variable list --repo $repo | Where-Object { $_ -match "AZURE_" }

Write-Host ""
Write-Host "=== Configuration Complete! ===" -ForegroundColor Green
Write-Host "Your GitHub repository is now configured with:" -ForegroundColor Yellow
Write-Host "  ✅ Azure OIDC authentication secrets" -ForegroundColor White
Write-Host "  ✅ Environment-specific subscription variables" -ForegroundColor White
Write-Host "  ✅ Ready for Terraform deployments" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Test the pipeline by creating a feature branch" -ForegroundColor White
Write-Host "  2. Make a small change to any .tf file" -ForegroundColor White
Write-Host "  3. Create a PR to 'develop' branch" -ForegroundColor White
Write-Host "  4. Check GitHub Actions for deployment progress" -ForegroundColor White
Write-Host ""
Write-Host "Your deployment pipeline is ready! 🚀" -ForegroundColor Green
