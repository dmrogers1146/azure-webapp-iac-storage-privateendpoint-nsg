output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gateway_public_ip.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the public IP"
  value       = azurerm_public_ip.app_gateway_public_ip.fqdn
}
