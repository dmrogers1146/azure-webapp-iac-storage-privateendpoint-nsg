output "virtual_network_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "app_gateway_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.app_gateway_subnet.id
}

output "private_endpoint_subnet_id" {
  description = "ID of the general Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoint_subnet.id
}

output "sql_private_endpoint_subnet_id" {
  description = "ID of the SQL Private Endpoint subnet"
  value       = azurerm_subnet.sql_private_endpoint_subnet.id
}

output "storage_private_endpoint_subnet_id" {
  description = "ID of the Storage Private Endpoint subnet"
  value       = azurerm_subnet.storage_private_endpoint_subnet.id
}

output "webapp_integration_subnet_id" {
  description = "ID of the Web App Integration subnet"
  value       = azurerm_subnet.webapp_integration_subnet.id
}
