# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Networking Module (must come first to create VNet and subnets)
module "networking" {
  source = "./modules/networking"

  virtual_network_name = "${var.resource_group_name}-vnet"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name

  tags = var.tags
}

# Web App Module
module "web_app" {
  source = "./modules/web_app"

  plan_name           = var.app_service_plan_name
  app_name            = var.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = var.app_service_sku
  key_vault_name      = "${var.key_vault_name}-${random_string.suffix.result}"
  subnet_id           = module.networking.webapp_integration_subnet_id
  enable_vnet_integration = true

  # Base app settings - Key Vault references will be added in the module
  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
  }

  tags = var.tags
}

# SQL Database Module
module "sql_database" {
  source = "./modules/sql_db"

  sql_server_name     = "${var.sql_server_name}-${random_string.suffix.result}"
  sql_database_name   = var.database_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
  subnet_id           = module.networking.sql_private_endpoint_subnet_id
  enable_private_endpoint = true

  # Backup and auditing configuration
  storage_endpoint      = module.storage_account.primary_blob_endpoint

  tags = var.tags
}

# Application Gateway Module
module "app_gateway" {
  source = "./modules/app_gateway"

  app_gateway_name     = var.app_gateway_name
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  subnet_id            = module.networking.app_gateway_subnet_id
  public_ip_name       = "${var.app_gateway_name}-pip"
  backend_fqdns        = [module.web_app.app_service_default_hostname]

  tags = var.tags
}

# Storage Account Module
module "storage_account" {
  source = "./modules/storage_account"

  storage_account_name = "${var.storage_account_name}${random_string.suffix.result}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  subnet_id            = module.networking.storage_private_endpoint_subnet_id
  allowed_subnet_ids   = [
    module.networking.webapp_integration_subnet_id,
    module.networking.sql_private_endpoint_subnet_id
  ]

  tags = var.tags
}

# Key Vault Module
module "key_vault" {
  source = "./modules/key_vault"

  key_vault_name             = "${var.key_vault_name}-${random_string.suffix.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  web_app_principal_id       = module.web_app.principal_id
  sql_admin_password         = var.sql_admin_password
  storage_connection_string  = module.storage_account.connection_string
  database_connection_string = module.sql_database.connection_string

  tags = var.tags
}
