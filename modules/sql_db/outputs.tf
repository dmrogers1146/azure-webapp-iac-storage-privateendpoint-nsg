output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.sql_database.name
}

output "connection_string" {
  description = "SQL Database connection string"
  value       = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sql_database.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the SQL Server private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.sql_pe[0].id : null
}

output "private_endpoint_private_ip" {
  description = "Private IP address of the SQL Server private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.sql_pe[0].private_service_connection[0].private_ip_address : null
}
