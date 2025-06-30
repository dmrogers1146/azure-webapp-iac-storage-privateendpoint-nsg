# Azure Web Application Infrastructure as Code!!

This repository contains a complete Infrastructure as Code (IaC) solution for deploying a secure, scalable web application infrastructure on Azure using Terraform.

## Architecture Overview

The infrastructure implements a **segregated network architecture** with enhanced security through private endpoints and network security groups:

### Core Components
- **Azure Web App (App Service)** - Hosts the web application with VNet integration
- **Azure SQL Database** - Managed database with private endpoint
- **Storage Account** - Application data storage with private endpoint  
- **Application Gateway** - Load balancer and web application firewall
- **Key Vault** - Secure secrets and connection string management

### Network Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network (10.0.0.0/16)           │
├─────────────────────────────────────────────────────────────┤
│ App Gateway Subnet        │ 10.0.1.0/24                    │
│ Private Endpoint Subnet   │ 10.0.2.0/24                    │
│ SQL Private Endpoint      │ 10.0.3.0/24                    │
│ Storage Private Endpoint  │ 10.0.4.0/24                    │
│ Web App Integration       │ 10.0.5.0/24                    │
└─────────────────────────────────────────────────────────────┘
```

### Security Features
- **Network Segregation**: Dedicated subnets for each service type
- **Private Endpoints**: SQL and Storage are not exposed to the internet
- **VNet Integration**: Web App communicates privately with backend services
- **NSG Rules**: Network Security Groups control traffic flow
- **Service Endpoints**: Optimized access to Azure services

## Repository Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions CI/CD pipeline
├── modules/                        # Terraform modules
│   ├── app_gateway/               # Application Gateway module
│   ├── key_vault/                 # Key Vault module  
│   ├── networking/                # VNet and subnets module
│   ├── sql_db/                    # SQL Database module
│   ├── storage_account/           # Storage Account module
│   └── web_app/                   # Web App module
├── backend.tf                     # Terraform backend configuration
├── main.tf                        # Root Terraform configuration
├── outputs.tf                     # Terraform outputs
├── variables.tf                   # Variable definitions
├── terraform.tfvars              # Variable values
└── README.md                      # This file
```

## Quick Start

### Prerequisites

1. **Azure CLI** - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform** - [Install Terraform](https://www.terraform.io/downloads.html) or use `winget install HashiCorp.Terraform`
3. **GitHub CLI** (optional) - [Install GitHub CLI](https://cli.github.com/)
4. **Azure Subscription** with appropriate permissions

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dmrogers1146/azure-webapp-iac-storage-privateendpoint-nsg.git
   cd azure-webapp-iac-storage-privateendpoint-nsg
   ```

2. **Login to Azure:**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

3. **Configure Terraform variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

4. **Initialize and apply Terraform:**
   ```bash
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```

## Terraform Configuration

### Backend Configuration
The infrastructure uses **local state** for development. For production, configure remote state storage:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "webapp.terraform.tfstate"
  }
}
```

### Key Variables
Configure these variables in `terraform.tfvars`:

```hcl
subscription_id         = "your-azure-subscription-id"
location               = "East US"
resource_group_name    = "myapp-dev-rg"
app_service_name       = "myapp-dev-web"
app_service_sku        = "S1"  # Must be S1 or higher for VNet integration
sql_server_name        = "myapp-dev-sql"
database_name          = "myapp-db"
storage_account_name   = "myappdevstorage"
app_gateway_name       = "myapp-dev-appgw"
key_vault_name         = "myapp-dev-kv"
sql_admin_username     = "sqladmin"
sql_admin_password     = "YourSecurePassword123!"
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The repository includes a comprehensive GitHub Actions workflow (`.github/workflows/deploy.yml`) that:

1. **Validates** Terraform configuration
2. **Plans** infrastructure changes
3. **Applies** changes (on main branch)
4. **Validates** successful deployment

### Pipeline Setup

#### 1. Create GitHub Environment
```bash
# Your repository: https://github.com/dmrogers1146/azure-webapp-iac-storage-privateendpoint-nsg
# Go to Settings > Environments > New environment
# Name: dev
```

#### 2. Create Service Principal (COMPLETED)
```bash
# Already created with these details:
# CLIENT_ID: 38e257dc-b252-4671-9547-f33b7841f713
# TENANT_ID: d357bf17-bbfe-45ca-861e-23fdfc24136a
# SUBSCRIPTION_ID: 34c068fd-ceb1-4bb7-96c6-00360b36cbcb
```

#### 3. Configure Federated Credentials (COMPLETED)
```bash
# Already configured for OIDC authentication
# Subject: repo:dmrogers1146/azure-webapp-iac-storage-privateendpoint-nsg:environment:dev
```

#### 4. Set GitHub Secrets
Add these secrets to your GitHub environment 'dev':
- AZURE_CLIENT_ID: 38e257dc-b252-4671-9547-f33b7841f713
- AZURE_TENANT_ID: d357bf17-bbfe-45ca-861e-23fdfc24136a  
- AZURE_SUBSCRIPTION_ID: 34c068fd-ceb1-4bb7-96c6-00360b36cbcb

### Branch Protection Rules

Configure branch protection for `main`:
1. Require pull request reviews
2. Require status checks to pass
3. Require branches to be up to date
4. Restrict pushes to main branch

## 🔒 Security Best Practices

### Network Security
- **Private Endpoints**: Database and storage are not internet-accessible
- **VNet Integration**: Web app communicates privately with backend services
- **NSG Rules**: Restrictive network security group rules
- **Service Endpoints**: Optimized, secure access to Azure services

### Access Control
- **Managed Identity**: Web app uses managed identity for Key Vault access
- **RBAC**: Least privilege access controls
- **Key Vault**: All secrets stored securely in Azure Key Vault
- **Connection Strings**: Fetched from Key Vault at runtime

### Monitoring
- **Application Insights**: Application performance monitoring (future enhancement)
- **Diagnostic Settings**: Resource-level logging (future enhancement)
- **Network Watcher**: Network traffic analysis (future enhancement)

## 🔄 Rollback Procedures

### Manual Rollback
```bash
# View previous state
terraform state list

# Import previous state or manually revert changes
terraform plan -destroy
terraform apply -destroy  # If complete rollback needed
```

### Pipeline Rollback
1. Revert the commit that caused issues
2. Push to main branch
3. Pipeline will automatically deploy previous configuration

### Emergency Procedures
```bash
# Force unlock if state is locked
terraform force-unlock LOCK_ID

# Import existing resources if state is corrupted
terraform import azurerm_resource_group.main /subscriptions/SUB_ID/resourceGroups/RG_NAME
```

## Outputs

After successful deployment, access your resources:

- **Application Gateway Public IP**: Use for accessing the web application
- **Web App URL**: Direct access to the App Service
- **Resource Group Name**: Container for all resources
- **Key Vault Name**: For accessing stored secrets

## Troubleshooting

### Common Issues

1. **VNet Integration Errors**: Ensure App Service SKU is S1 or higher
2. **Private Endpoint Issues**: Check NSG rules and subnet configurations
3. **Storage Access Errors**: Verify service endpoints are configured
4. **Pipeline Failures**: Check service principal permissions

### Validation Commands
```bash
# Check resource status
az group show --name myapp-dev-rg
az webapp show --name myapp-dev-web --resource-group myapp-dev-rg
az sql server show --name myapp-dev-sql --resource-group myapp-dev-rg

# Test connectivity
az webapp log download --name myapp-dev-web --resource-group myapp-dev-rg
```

## Demo Checklist

For the 10-15 minute walkthrough:

1. **Architecture Overview** (2-3 minutes)
   - Show network diagram
   - Explain security enhancements
   - Highlight private endpoints

2. **Repository Structure** (2-3 minutes)
   - Terraform modules organization
   - GitHub Actions workflow
   - Branch protection setup

3. **Live Demo** (8-10 minutes)
   - Make a small infrastructure change
   - Show pull request workflow
   - Demonstrate pipeline execution
   - Validate deployed changes

4. **Rollback Demo** (2 minutes)
   - Show how to revert changes
   - Explain emergency procedures

## 🤝 Contributing

1. Create feature branch from `develop`
2. Make changes and test locally
3. Create pull request to `main`
4. Ensure pipeline passes
5. Merge after review

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)
- [GitHub Actions for Azure](https://docs.microsoft.com/en-us/azure/developer/github/github-actions)
- [Azure Private Endpoints](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
