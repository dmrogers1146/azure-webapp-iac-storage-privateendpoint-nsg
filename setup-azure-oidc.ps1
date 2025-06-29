#!/usr/bin/env pwsh
# Azure OIDC Setup Script for GitHub Actions
# This script helps set up OIDC authentication between GitHub Actions and Azure

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubOrg,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo,
    
    [Parameter(Mandatory=$true)]
    [string]$ServicePrincipalName = "sp-terraform-github-actions"
)

Write-Host "=== Azure OIDC Setup for GitHub Actions ===" -ForegroundColor Cyan
Write-Host "GitHub Organization: $GitHubOrg" -ForegroundColor Green
Write-Host "GitHub Repository: $GitHubRepo" -ForegroundColor Green
Write-Host "Service Principal Name: $ServicePrincipalName" -ForegroundColor Green
Write-Host ""

# Get current subscription details
Write-Host "Getting current Azure subscription..." -ForegroundColor Yellow
$subscription = az account show --query "{subscriptionId:id, tenantId:tenantId}" | ConvertFrom-Json

Write-Host "Current Subscription ID: $($subscription.subscriptionId)" -ForegroundColor Green
Write-Host "Tenant ID: $($subscription.tenantId)" -ForegroundColor Green
Write-Host ""

# Create service principal
Write-Host "Creating service principal..." -ForegroundColor Yellow
$sp = az ad sp create-for-rbac --name $ServicePrincipalName --role Contributor --scopes "/subscriptions/$($subscription.subscriptionId)" --query "{clientId:appId, objectId:id}" | ConvertFrom-Json

Write-Host "Service Principal created:" -ForegroundColor Green
Write-Host "  Client ID: $($sp.clientId)" -ForegroundColor Green
Write-Host "  Object ID: $($sp.objectId)" -ForegroundColor Green
Write-Host ""

# Create federated credentials for different scenarios
$credentials = @(
    @{
        name = "main-branch"
        issuer = "https://token.actions.githubusercontent.com"
        subject = "repo:$GitHubOrg/$GitHubRepo:ref:refs/heads/main"
        description = "GitHub Actions - Main Branch"
    },
    @{
        name = "develop-branch"
        issuer = "https://token.actions.githubusercontent.com"
        subject = "repo:$GitHubOrg/$GitHubRepo:ref:refs/heads/develop"
        description = "GitHub Actions - Develop Branch"
    },
    @{
        name = "pull-requests"
        issuer = "https://token.actions.githubusercontent.com"
        subject = "repo:$GitHubOrg/$GitHubRepo:pull_request"
        description = "GitHub Actions - Pull Requests"
    }
)

Write-Host "Creating federated credentials..." -ForegroundColor Yellow
foreach ($cred in $credentials) {
    Write-Host "  Creating credential: $($cred.name)" -ForegroundColor Gray
    
    $credJson = @{
        name = $cred.name
        issuer = $cred.issuer
        subject = $cred.subject
        description = $cred.description
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json -Compress
    
    az ad app federated-credential create --id $sp.clientId --parameters $credJson | Out-Null
}

Write-Host ""
Write-Host "=== GitHub Secrets Setup ===" -ForegroundColor Cyan
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Secrets:" -ForegroundColor Green
Write-Host "  AZURE_CLIENT_ID: $($sp.clientId)" -ForegroundColor White
Write-Host "  AZURE_TENANT_ID: $($subscription.tenantId)" -ForegroundColor White
Write-Host ""
Write-Host "Variables:" -ForegroundColor Green
Write-Host "  AZURE_SUBSCRIPTION_ID_DEV: a8912e4d-93c4-4867-ab0d-1095943662fd" -ForegroundColor White
Write-Host "  AZURE_SUBSCRIPTION_ID_PROD: 34c068fd-ceb1-4bb7-96c6-00360b36cbcb" -ForegroundColor White
Write-Host ""

Write-Host "=== Additional Setup Required ===" -ForegroundColor Cyan
Write-Host "1. Grant the service principal access to both subscriptions:" -ForegroundColor Yellow
Write-Host "   - Development: a8912e4d-93c4-4867-ab0d-1095943662fd" -ForegroundColor White
Write-Host "   - Production: 34c068fd-ceb1-4bb7-96c6-00360b36cbcb" -ForegroundColor White
Write-Host ""
Write-Host "2. Run the following commands to grant access:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Grant access to development subscription" -ForegroundColor Gray
Write-Host "az role assignment create --assignee $($sp.clientId) --role Contributor --scope '/subscriptions/a8912e4d-93c4-4867-ab0d-1095943662fd'" -ForegroundColor White
Write-Host ""
Write-Host "# Grant access to production subscription" -ForegroundColor Gray
Write-Host "az role assignment create --assignee $($sp.clientId) --role Contributor --scope '/subscriptions/34c068fd-ceb1-4bb7-96c6-00360b36cbcb'" -ForegroundColor White
Write-Host ""

Write-Host "3. Configure GitHub Environment Protection (optional):" -ForegroundColor Yellow
Write-Host "   - Go to repository Settings > Environments" -ForegroundColor White
Write-Host "   - Create 'prod' environment with required reviewers" -ForegroundColor White
Write-Host "   - Create 'dev' environment (no restrictions needed)" -ForegroundColor White
Write-Host ""

Write-Host "Setup completed successfully!" -ForegroundColor Green
