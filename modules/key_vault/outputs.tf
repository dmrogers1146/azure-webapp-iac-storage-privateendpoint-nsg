output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.key_vault.vault_uri
}

output "sql_admin_password_secret_id" {
  description = "ID of the SQL admin password secret"
  value       = azurerm_key_vault_secret.sql_admin_password.id
}

output "storage_connection_string_secret_id" {
  description = "ID of the storage connection string secret"
  value       = azurerm_key_vault_secret.storage_connection_string.id
}

output "database_connection_string_secret_id" {
  description = "ID of the database connection string secret"
  value       = azurerm_key_vault_secret.database_connection_string.id
}

# Key Vault references for app settings
output "sql_admin_password_reference" {
  description = "Key Vault reference for SQL admin password"
  value       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_admin_password.id})"
}

output "storage_connection_string_reference" {
  description = "Key Vault reference for storage connection string"
  value       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_connection_string.id})"
}

output "database_connection_string_reference" {
  description = "Key Vault reference for database connection string"
  value       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_connection_string.id})"
}
