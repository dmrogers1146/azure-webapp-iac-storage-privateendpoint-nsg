# Azure Infrastructure Deployment Script (PowerShell)
# This script automates the Terraform deployment process with proper validation

param(
    [switch]$AutoApprove,
    [switch]$PlanOnly,
    [switch]$Destroy
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    try {
        $null = Get-Command az -ErrorAction Stop
    }
    catch {
        Write-Error "Azure CLI is not installed. Please install it first."
        exit 1
    }
    
    # Check if Terraform is installed
    try {
        $null = Get-Command terraform -ErrorAction Stop
    }
    catch {
        Write-Error "Terraform is not installed. Please install it first."
        Write-Status "You can install Terraform using: winget install HashiCorp.Terraform"
        exit 1
    }
    
    # Check if logged into Azure
    try {
        $null = az account show --output none 2>$null
    }
    catch {
        Write-Error "Not logged into Azure. Please run 'az login' first."
        exit 1
    }
    
    # Check if terraform.tfvars exists
    if (-not (Test-Path "terraform.tfvars")) {
        Write-Error "terraform.tfvars not found. Please copy terraform.tfvars.example and customize it."
        exit 1
    }
    
    Write-Success "All prerequisites met!"
}

# Function to validate Terraform configuration
function Test-TerraformConfiguration {
    Write-Status "Validating Terraform configuration..."
    
    # Format check
    $formatResult = terraform fmt -check
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Terraform files are not properly formatted. Running terraform fmt..."
        terraform fmt
    }
    
    # Validate configuration
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform configuration validation failed!"
        exit 1
    }
    
    Write-Success "Terraform configuration is valid!"
}

# Function to run Terraform plan
function Invoke-TerraformPlan {
    Write-Status "Running Terraform plan..."
    
    if ($Destroy) {
        terraform plan -destroy -detailed-exitcode -out=tfplan
    } else {
        terraform plan -detailed-exitcode -out=tfplan
    }
    
    $planExitCode = $LASTEXITCODE
    
    switch ($planExitCode) {
        0 {
            Write-Success "No changes needed. Infrastructure matches configuration."
            return 0
        }
        1 {
            Write-Error "Terraform plan failed!"
            return 1
        }
        2 {
            Write-Warning "Changes detected! Review the plan above."
            return 2
        }
    }
}

# Function to apply Terraform changes
function Invoke-TerraformApply {
    Write-Status "Applying Terraform changes..."
    
    terraform apply tfplan
    if ($LASTEXITCODE -eq 0) {
        if ($Destroy) {
            Write-Success "Infrastructure destroyed successfully!"
        } else {
            Write-Success "Infrastructure deployed successfully!"
            
            # Show outputs
            Write-Status "Deployment outputs:"
            terraform output
        }
    } else {
        Write-Error "Terraform apply failed!"
        return 1
    }
}

# Function to validate deployment
function Test-Deployment {
    if ($Destroy) {
        Write-Status "Destroy operation completed."
        return
    }
    
    Write-Status "Validating deployment..."
    
    try {
        # Get resource group name from terraform output
        $rgName = terraform output -raw resource_group_name 2>$null
        
        if ($rgName) {
            Write-Status "Checking resources in resource group: $rgName"
            
            # Check if resource group exists
            $rgExists = az group show --name $rgName --query "name" -o tsv 2>$null
            if ($rgExists) {
                Write-Success "Resource group '$rgName' exists"
                
                # List all resources in the group
                Write-Status "Resources deployed:"
                az resource list --resource-group $rgName --query "[].{Name:name, Type:type, Location:location}" --output table
            } else {
                Write-Error "Resource group '$rgName' not found!"
                return 1
            }
        } else {
            Write-Warning "Could not retrieve resource group name from Terraform outputs"
        }
    }
    catch {
        Write-Warning "Could not validate deployment: $($_.Exception.Message)"
    }
}

# Function to clean up
function Remove-TempFiles {
    Write-Status "Cleaning up temporary files..."
    if (Test-Path "tfplan") {
        Remove-Item "tfplan" -Force
    }
}

# Main execution
function Main {
    if ($Destroy) {
        Write-Status "Starting Azure Infrastructure Destruction..."
    } else {
        Write-Status "Starting Azure Infrastructure Deployment..."
    }
    Write-Status "================================================"
    
    try {
        # Run all steps
        Test-Prerequisites
        
        Write-Status "Initializing Terraform..."
        terraform init
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Terraform init failed!"
            exit 1
        }
        
        Test-TerraformConfiguration
        
        $planResult = Invoke-TerraformPlan
        
        if ($PlanOnly) {
            Write-Status "Plan-only mode. Exiting after plan."
            return
        }
        
        switch ($planResult) {
            0 {
                if ($Destroy) {
                    Write-Success "No resources to destroy!"
                } else {
                    Write-Success "No deployment needed!"
                }
            }
            1 {
                Write-Error "Plan failed. Aborting."
                exit 1
            }
            2 {
                if ($AutoApprove) {
                    Invoke-TerraformApply
                    Test-Deployment
                } else {
                    $response = Read-Host "Do you want to apply these changes? (y/N)"
                    if ($response -match "^[Yy]$") {
                        Invoke-TerraformApply
                        Test-Deployment
                    } else {
                        Write-Status "Operation cancelled by user."
                    }
                }
            }
        }
        
        if ($Destroy) {
            Write-Success "Destruction script completed!"
        } else {
            Write-Success "Deployment script completed!"
        }
    }
    finally {
        Remove-TempFiles
    }
}

# Show usage if help is requested
if ($args -contains "-help" -or $args -contains "--help" -or $args -contains "-h") {
    Write-Host @"
Azure Infrastructure Deployment Script

Usage:
    .\deploy.ps1 [options]

Options:
    -AutoApprove    Apply changes without confirmation
    -PlanOnly       Only run terraform plan, don't apply
    -Destroy        Destroy infrastructure instead of creating it
    -h, -help       Show this help message

Examples:
    .\deploy.ps1                    # Interactive deployment
    .\deploy.ps1 -AutoApprove       # Auto-approve deployment
    .\deploy.ps1 -PlanOnly          # Only show plan
    .\deploy.ps1 -Destroy           # Destroy infrastructure
"@
    exit 0
}

# Run main function
Main
