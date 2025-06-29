# Terraform Workspace Management Script (PowerShell)
# Usage: .\manage-workspace.ps1 [dev|staging|prod] [init|plan|apply|destroy]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("init", "plan", "apply", "destroy")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

# Set workspace and variable file
$Workspace = $Environment
$VarFile = "environments\$Environment.tfvars"

Write-Host "🚀 Managing Terraform workspace: $Workspace" -ForegroundColor Green
Write-Host "📁 Using variable file: $VarFile" -ForegroundColor Yellow

# Check if variable file exists
if (-not (Test-Path $VarFile)) {
    Write-Host "❌ Error: Variable file $VarFile not found" -ForegroundColor Red
    exit 1
}

switch ($Action) {
    "init" {
        Write-Host "🔧 Initializing Terraform..." -ForegroundColor Blue
        terraform init
        
        Write-Host "🏗️  Creating/selecting workspace: $Workspace" -ForegroundColor Blue
        $workspaceExists = terraform workspace list | Select-String $Workspace
        if ($workspaceExists) {
            terraform workspace select $Workspace
        } else {
            terraform workspace new $Workspace
        }
        
        Write-Host "✅ Workspace $Workspace is ready" -ForegroundColor Green
    }
    
    "plan" {
        Write-Host "📋 Planning changes for $Environment environment..." -ForegroundColor Blue
        terraform workspace select $Workspace
        terraform plan -var-file="$VarFile" -out="tfplan-$Environment"
    }
    
    "apply" {
        Write-Host "🚀 Applying changes for $Environment environment..." -ForegroundColor Blue
        terraform workspace select $Workspace
        
        if (Test-Path "tfplan-$Environment") {
            Write-Host "📦 Using existing plan file: tfplan-$Environment" -ForegroundColor Yellow
            terraform apply "tfplan-$Environment"
        } else {
            Write-Host "⚠️  No plan file found, running plan and apply..." -ForegroundColor Yellow
            terraform apply -var-file="$VarFile"
        }
    }
    
    "destroy" {
        Write-Host "💥 Destroying resources for $Environment environment..." -ForegroundColor Red
        Write-Host "⚠️  This will destroy all resources in the $Environment environment!" -ForegroundColor Yellow
        $confirm = Read-Host "Are you sure? Type 'yes' to continue"
        
        if ($confirm -eq "yes") {
            terraform workspace select $Workspace
            terraform destroy -var-file="$VarFile"
        } else {
            Write-Host "❌ Destroy cancelled" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "✅ Action '$Action' completed for environment '$Environment'" -ForegroundColor Green
