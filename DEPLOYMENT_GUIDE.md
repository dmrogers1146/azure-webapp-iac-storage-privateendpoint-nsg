# Terraform Deployment Pipeline Documentation

## Overview

This documentation describes the robust, branch-based Terraform deployment workflow for Azure using GitHub Actions. The pipeline supports environment-specific deployments with separate Azure subscriptions for development and production environments.

## Architecture

- **Development Environment**: Triggered by commits to `develop` branch
  - Azure Subscription: `a8912e4d-93c4-4867-ab0d-1095943662fd`
  - Terraform Workspace: `dev`
  - Configuration: `environments/dev.tfvars`

- **Production Environment**: Triggered by commits to `main` branch
  - Azure Subscription: `34c068fd-ceb1-4bb7-96c6-00360b36cbcb`
  - Terraform Workspace: `prod`
  - Configuration: `environments/prod.tfvars`

## Prerequisites

### Azure Setup

1. **Service Principal with OIDC**: Create a service principal for GitHub Actions with OIDC authentication
2. **Federated Credentials**: Configure federated credentials for your GitHub repository
3. **RBAC Permissions**: Assign appropriate permissions to the service principal for both subscriptions

### GitHub Secrets and Variables

#### Required Secrets
- `AZURE_CLIENT_ID`: The application (client) ID of the service principal
- `AZURE_TENANT_ID`: The tenant ID of your Azure Active Directory

#### Required Variables
- `AZURE_SUBSCRIPTION_ID_DEV`: Development subscription ID (`a8912e4d-93c4-4867-ab0d-1095943662fd`)
- `AZURE_SUBSCRIPTION_ID_PROD`: Production subscription ID (`34c068fd-ceb1-4bb7-96c6-00360b36cbcb`)

## Workflow Triggers

### Automatic Deployments
- **Push to `develop`**: Deploys to development environment
- **Push to `main`**: Deploys to production environment

### Manual Deployments
- **Workflow Dispatch**: Manually trigger deployment to any environment via GitHub UI

### Pull Requests
- **PR to `main`**: Runs Terraform plan and posts results as PR comment

## Environment Configuration

Each environment has its own configuration file in the `environments/` directory:

### Development (`environments/dev.tfvars`)
- Lower-cost SKUs for cost optimization
- Basic security configurations
- Development-specific naming conventions

### Production (`environments/prod.tfvars`)
- Premium SKUs for high availability
- Enhanced security features (WAF, Zone-redundant storage)
- Production-specific naming conventions

## Local Development

### Using the Workspace Manager Script

The `workspace-manager.ps1` script automates local Terraform operations:

```powershell
# Initialize and plan for development
.\workspace-manager.ps1 -Environment dev -Action init
.\workspace-manager.ps1 -Environment dev -Action plan

# Apply changes to development
.\workspace-manager.ps1 -Environment dev -Action apply

# Apply with auto-approval
.\workspace-manager.ps1 -Environment dev -Action apply -AutoApprove

# Destroy resources
.\workspace-manager.ps1 -Environment dev -Action destroy
```

### Manual Terraform Commands

```bash
# Set Azure subscription for development
az account set --subscription a8912e4d-93c4-4867-ab0d-1095943662fd

# Initialize Terraform
terraform init

# Create/select workspace
terraform workspace new dev
terraform workspace select dev

# Plan with environment-specific variables
terraform plan -var-file="environments/dev.tfvars"

# Apply changes
terraform apply -var-file="environments/dev.tfvars"
```

## CI/CD Pipeline Jobs

### 1. Determine Environment
- Analyzes the branch or manual input to determine target environment
- Sets workspace and variable file paths
- Determines if deployment should proceed

### 2. Terraform Plan
- Authenticates to Azure using OIDC
- Initializes Terraform and selects appropriate workspace
- Validates Terraform configuration
- Creates execution plan with environment-specific variables
- Posts plan results to PR comments (for pull requests)
- Uploads plan artifact for apply job

### 3. Terraform Apply
- Downloads plan artifact from plan job
- Authenticates to Azure using OIDC
- Applies the previously created plan
- Captures deployment outputs (URLs, resource names)
- Performs post-deployment validation

## Security Features

- **OIDC Authentication**: No long-lived secrets stored in GitHub
- **Environment Isolation**: Separate Azure subscriptions for dev/prod
- **Workspace Isolation**: Terraform workspaces prevent state mixing
- **Least Privilege**: Service principal has minimal required permissions
- **Environment Protection**: GitHub environment rules can require approvals

## Monitoring and Troubleshooting

### GitHub Actions Logs
- Check workflow execution logs in GitHub Actions tab
- Each job provides detailed output for debugging

### Azure Portal
- Monitor resource deployments in Azure portal
- Check activity logs for deployment status

### Terraform State
- State files are stored in Azure Storage backend
- Each workspace maintains separate state

## Best Practices

1. **Branch Protection**: Enable branch protection on `main` branch
2. **Required Reviews**: Require PR reviews before merging to `main`
3. **Environment Approvals**: Configure GitHub environment protection rules
4. **Resource Tagging**: All resources include environment and project tags
5. **Cost Management**: Use appropriate SKUs for each environment
6. **State Management**: Never manually edit Terraform state files

## Troubleshooting Common Issues

### Authentication Errors
- Verify service principal permissions in Azure
- Check federated credential configuration
- Ensure GitHub secrets are correctly set

### Terraform Errors
- Review Terraform validate output
- Check variable file syntax
- Verify resource quotas in target subscription

### State Lock Issues
- Check Azure Storage blob lease status
- Use `terraform force-unlock` if necessary (with caution)

## Adding New Environments

To add a new environment (e.g., staging):

1. Create new variable file: `environments/staging.tfvars`
2. Update GitHub workflow to include staging branch
3. Add staging subscription ID to GitHub variables
4. Update workspace manager script validation
5. Configure environment protection rules in GitHub

## Support and Maintenance

- Regularly update Terraform version in workflow
- Monitor Azure subscription quotas
- Review and rotate service principal credentials
- Update resource configurations as needed
- Maintain environment parity where possible

## Interview Demo - GitHub Branch Protection & Deployment Workflow

### Phase 1: Create Feature Branch & Make Changes

```powershell
# 1. Create and switch to feature branch
git checkout -b feature/demo-change

# 2. Make a small infrastructure change (for demo)
# Edit terraform.tfvars - change a tag or add a comment
notepad terraform.tfvars

# 3. Commit the change
git add .
git commit -m "Demo: Update infrastructure configuration"

# 4. Push feature branch
git push -u origin feature/demo-change
```

### Phase 2: Create Pull Request (GitHub Web UI)

```bash
# 5. Go to GitHub repository in browser
# 6. Click "Compare & pull request" button
# 7. Add title: "Demo: Infrastructure update"
# 8. Add description of changes
# 9. Click "Create pull request"
```

### Phase 3: Demonstrate Branch Protection

```powershell
# 10. Try to push directly to main (this should fail)
git checkout main
git merge feature/demo-change
git push origin main
# This will fail due to branch protection!
```

### Phase 4: Proper Workflow - Merge via PR

```bash
# 11. Go back to GitHub PR
# 12. Review the changes
# 13. Check that CI/CD pipeline runs
# 14. Approve and merge the PR
# 15. Delete the feature branch
```

### Phase 5: Monitor Deployment

```powershell
# 16. Switch back to main and pull changes
git checkout main
git pull origin main

# 17. Check GitHub Actions for deployment status
# Go to Actions tab in GitHub

# 18. Monitor Azure resources
az group list --query "[?contains(name, 'webapp-payg')].name" -o table

# 19. Verify deployment outputs
terraform output
```

### Phase 6: Validate Live Application

```powershell
# 20. Test the deployed application
# Use the URLs from terraform output
curl https://app-webapp-payg-demo.azurewebsites.net

# 21. Check Application Gateway
curl http://20.125.46.23
```

## Interview Talking Points

1. **Branch Protection**: "Direct pushes to main are blocked, enforcing code review"
2. **CI/CD Pipeline**: "Every PR triggers automated testing and validation"
3. **Infrastructure as Code**: "Terraform manages all Azure resources consistently"
4. **Security**: "Service principals with minimal permissions, Key Vault for secrets"
5. **Monitoring**: "Can track deployments through GitHub Actions and Azure portal"

## Interview Questions You Can Answer

- **"How do you ensure code quality?"** → Branch protection + PR reviews
- **"How do you deploy to Azure?"** → GitHub Actions with Terraform
- **"How do you handle secrets?"** → Azure Key Vault + GitHub secrets
- **"How do you prevent direct production changes?"** → Branch protection rules
- **"How do you rollback deployments?"** → Terraform state management + git revert

## Complete Destroy/Rebuild Test Commands

### Destroy Current Infrastructure

```powershell
# Check current state
terraform output

# Destroy all resources
terraform destroy -auto-approve

# Verify destruction
az group list --query "[?contains(name, 'webapp-payg')].name" -o table
```

### Rebuild Infrastructure

```powershell
# Rebuild from scratch
terraform apply -auto-approve

# Verify outputs
terraform output

# Test application
curl $(terraform output -raw app_service_url)
```
