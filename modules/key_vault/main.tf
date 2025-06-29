# GitHub Copilot Prompt:
# I'm creating an Azure App Service infrastructure using Terraform.
# Please generate Terraform code that:
#
# 1. Provisions an App Service with a System Assigned Managed Identity
#    - Use azurerm_app_service and azurerm_app_service_plan
#    - Assign the managed identity automatically
#
# 2. Creates an Azure Key Vault
#    - Restrict access using Key Vault Access Policies
#    - Allow the App Service's Managed Identity to read secrets
#    - Store a secret like `sql-connection-string`
#
# 3. Uses Terraform to retrieve a secret from the Key Vault
#    - Use data source azurerm_key_vault_secret
#    - Inject the secret into the App Service's application settings as an environment variable
#
# Security Requirements:
# - Do NOT hardcode secrets
# - Do NOT output secret values
# - Use `sensitive = true` for variables
#
# Optional Enhancements:
# - Enable diagnostic settings for monitoring
# - Use variables for all names and locations

# Get current user data for Key Vault access
data "azurerm_client_config" "current" {}

# Azure Key Vault with Access Policies (not RBAC)
resource "azurerm_key_vault" "key_vault" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  # Use Access Policies instead of RBAC
  enable_rbac_authorization = false

  # Access policy for current user (for deployment)
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover", "Purge"
    ]
  }

  # Network access rules
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Access policy for web app managed identity
resource "azurerm_key_vault_access_policy" "web_app_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.web_app_principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Store SQL admin password in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.key_vault.id

  tags = var.tags
}

# Store storage connection string in Key Vault
resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "storage-connection-string"
  value        = var.storage_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id

  tags = var.tags
}

# Store database connection string in Key Vault
resource "azurerm_key_vault_secret" "database_connection_string" {
  name         = "database-connection-string"
  value        = var.database_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id

  tags = var.tags
}
