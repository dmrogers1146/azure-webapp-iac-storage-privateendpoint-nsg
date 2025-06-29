#!/bin/bash

# Azure Infrastructure Deployment Script
# This script automates the Terraform deployment process with proper validation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars not found. Please copy terraform.tfvars.example and customize it."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Function to validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    
    terraform fmt -check
    if [ $? -ne 0 ]; then
        print_warning "Terraform files are not properly formatted. Running terraform fmt..."
        terraform fmt
    fi
    
    terraform validate
    print_success "Terraform configuration is valid!"
}

# Function to run Terraform plan
run_plan() {
    print_status "Running Terraform plan..."
    
    terraform plan -detailed-exitcode -out=tfplan
    plan_exit_code=$?
    
    case $plan_exit_code in
        0)
            print_success "No changes needed. Infrastructure matches configuration."
            return 0
            ;;
        1)
            print_error "Terraform plan failed!"
            return 1
            ;;
        2)
            print_warning "Changes detected! Review the plan above."
            return 2
            ;;
    esac
}

# Function to apply Terraform changes
apply_changes() {
    print_status "Applying Terraform changes..."
    
    terraform apply tfplan
    if [ $? -eq 0 ]; then
        print_success "Infrastructure deployed successfully!"
        
        # Show outputs
        print_status "Deployment outputs:"
        terraform output
    else
        print_error "Terraform apply failed!"
        return 1
    fi
}

# Function to validate deployment
validate_deployment() {
    print_status "Validating deployment..."
    
    # Get resource group name from terraform output
    RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null)
    
    if [ -n "$RG_NAME" ]; then
        print_status "Checking resources in resource group: $RG_NAME"
        
        # Check if resource group exists
        if az group show --name "$RG_NAME" &> /dev/null; then
            print_success "Resource group '$RG_NAME' exists"
            
            # List all resources in the group
            print_status "Resources deployed:"
            az resource list --resource-group "$RG_NAME" --query "[].{Name:name, Type:type, Location:location}" --output table
        else
            print_error "Resource group '$RG_NAME' not found!"
            return 1
        fi
    else
        print_warning "Could not retrieve resource group name from Terraform outputs"
    fi
}

# Function to clean up
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -f tfplan
}

# Main execution
main() {
    print_status "Starting Azure Infrastructure Deployment..."
    print_status "================================================"
    
    # Trap to ensure cleanup on exit
    trap cleanup EXIT
    
    # Run all steps
    check_prerequisites
    
    print_status "Initializing Terraform..."
    terraform init
    
    validate_terraform
    
    if run_plan; then
        case $? in
            0)
                print_success "No deployment needed!"
                ;;
            2)
                read -p "Do you want to apply these changes? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    apply_changes
                    validate_deployment
                else
                    print_status "Deployment cancelled by user."
                fi
                ;;
        esac
    else
        print_error "Plan failed. Aborting deployment."
        exit 1
    fi
    
    print_success "Deployment script completed!"
}

# Run main function
main "$@"
