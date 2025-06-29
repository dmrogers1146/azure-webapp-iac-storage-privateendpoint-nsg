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
