# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on = var.sku_name == "F1" ? false : true

    application_stack {
      dotnet_version = "6.0"
    }
  }

  # Enhanced app settings with Key Vault references when Key Vault is provided
  app_settings = var.key_vault_name != null ? merge(var.app_settings, {
    "ConnectionStrings__DefaultConnection" = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=database-connection-string)"
    "ConnectionStrings__Storage"           = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=storage-connection-string)"
  }) : var.app_settings

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  tags = var.tags
}

# VNet Integration for Web App
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count          = var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.subnet_id
}
