#!/usr/bin/env pwsh
# Terraform Workspace Management Script
# This script helps manage Terraform workspaces with different Azure subscriptions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("plan", "apply", "destroy", "init")]
    [string]$Action,
    
    [switch]$AutoApprove
)

# Environment to subscription mapping
$subscriptionMap = @{
    "dev"  = "a8912e4d-93c4-4867-ab0d-1095943662fd"
    "prod" = "34c068fd-ceb1-4bb7-96c6-00360b36cbcb"
}

Write-Host "=== Terraform Workspace Manager ===" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Green
Write-Host "Subscription: $($subscriptionMap[$Environment])" -ForegroundColor Green
Write-Host ""

# Set the Azure subscription
Write-Host "Setting Azure subscription..." -ForegroundColor Yellow
az account set --subscription $subscriptionMap[$Environment]
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to set Azure subscription"
    exit 1
}

# Initialize Terraform if needed
if ($Action -eq "init") {
    Write-Host "Initializing Terraform..." -ForegroundColor Yellow
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform init failed"
        exit 1
    }
}

# Create or select workspace
Write-Host "Managing Terraform workspace: $Environment" -ForegroundColor Yellow
terraform workspace select $Environment 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Workspace '$Environment' doesn't exist, creating it..." -ForegroundColor Yellow
    terraform workspace new $Environment
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create workspace"
        exit 1
    }
}

# Execute the requested action
$varFile = "environments\$Environment.tfvars"
Write-Host "Using variable file: $varFile" -ForegroundColor Yellow

switch ($Action) {
    "plan" {
        terraform plan -var-file=$varFile
    }
    "apply" {
        if ($AutoApprove) {
            terraform apply -var-file=$varFile -auto-approve
        } else {
            terraform apply -var-file=$varFile
        }
    }
    "destroy" {
        if ($AutoApprove) {
            terraform destroy -var-file=$varFile -auto-approve
        } else {
            terraform destroy -var-file=$varFile
        }
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Action '$Action' completed successfully!" -ForegroundColor Green
} else {
    Write-Error "Action '$Action' failed"
    exit 1
}
