# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Web App Outputs
output "app_service_name" {
  description = "Name of the App Service"
  value       = module.web_app.app_service_name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${module.web_app.app_service_default_hostname}"
}

output "app_service_hostname" {
  description = "Default hostname of the App Service"
  value       = module.web_app.app_service_default_hostname
}

# SQL Database Outputs
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.sql_database.sql_server_name
}

output "sql_server_fqdn" {
  description = "FQDN of the SQL Server"
  value       = module.sql_database.sql_server_fqdn
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.sql_database.sql_database_name
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = module.storage_account.storage_account_name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint of the Storage Account"
  value       = module.storage_account.primary_blob_endpoint
}

# Application Gateway Outputs
output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = module.app_gateway.application_gateway_name
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.app_gateway.public_ip_address
}

output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = module.networking.virtual_network_name
}

# Key Vault Outputs
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}
