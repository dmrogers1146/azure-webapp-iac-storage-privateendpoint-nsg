#!/bin/bash

# Terraform Workspace Management Script
# Usage: ./manage-workspace.sh [dev|staging|prod] [init|plan|apply|destroy]

set -e

ENVIRONMENT=$1
ACTION=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 [dev|staging|prod] [init|plan|apply|destroy]"
    echo ""
    echo "Examples:"
    echo "  $0 dev init     # Initialize development workspace"
    echo "  $0 dev plan     # Plan development changes"
    echo "  $0 staging apply # Apply staging changes"
    echo "  $0 prod destroy  # Destroy production resources"
    exit 1
fi

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        ;;
    *)
        echo "Error: Environment must be one of: dev, staging, prod"
        exit 1
        ;;
esac

# Set workspace and variable file
WORKSPACE=$ENVIRONMENT
VAR_FILE="environments/${ENVIRONMENT}.tfvars"

echo "🚀 Managing Terraform workspace: $WORKSPACE"
echo "📁 Using variable file: $VAR_FILE"

# Check if variable file exists
if [ ! -f "$VAR_FILE" ]; then
    echo "❌ Error: Variable file $VAR_FILE not found"
    exit 1
fi

case $ACTION in
    init)
        echo "🔧 Initializing Terraform..."
        terraform init
        
        echo "🏗️  Creating/selecting workspace: $WORKSPACE"
        terraform workspace select $WORKSPACE 2>/dev/null || terraform workspace new $WORKSPACE
        
        echo "✅ Workspace $WORKSPACE is ready"
        ;;
        
    plan)
        echo "📋 Planning changes for $ENVIRONMENT environment..."
        terraform workspace select $WORKSPACE
        terraform plan -var-file="$VAR_FILE" -out="tfplan-$ENVIRONMENT"
        ;;
        
    apply)
        echo "🚀 Applying changes for $ENVIRONMENT environment..."
        terraform workspace select $WORKSPACE
        
        if [ -f "tfplan-$ENVIRONMENT" ]; then
            echo "📦 Using existing plan file: tfplan-$ENVIRONMENT"
            terraform apply "tfplan-$ENVIRONMENT"
        else
            echo "⚠️  No plan file found, running plan and apply..."
            terraform apply -var-file="$VAR_FILE"
        fi
        ;;
        
    destroy)
        echo "💥 Destroying resources for $ENVIRONMENT environment..."
        echo "⚠️  This will destroy all resources in the $ENVIRONMENT environment!"
        read -p "Are you sure? Type 'yes' to continue: " confirm
        
        if [ "$confirm" = "yes" ]; then
            terraform workspace select $WORKSPACE
            terraform destroy -var-file="$VAR_FILE"
        else
            echo "❌ Destroy cancelled"
            exit 1
        fi
        ;;
        
    *)
        echo "❌ Error: Action must be one of: init, plan, apply, destroy"
        exit 1
        ;;
esac

echo "✅ Action '$ACTION' completed for environment '$ENVIRONMENT'"
