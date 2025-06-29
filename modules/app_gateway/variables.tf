variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = null
}

variable "subnet_name" {
  description = "Name of the subnet for Application Gateway"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID of the subnet for Application Gateway"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the public IP"
  type        = string
}

variable "backend_address_pool_name" {
  description = "Name of the backend address pool"
  type        = string
  default     = "appGatewayBackendPool"
}

variable "frontend_port_name" {
  description = "Name of the frontend port"
  type        = string
  default     = "appGatewayFrontendPort"
}

variable "frontend_ip_configuration_name" {
  description = "Name of the frontend IP configuration"
  type        = string
  default     = "appGatewayFrontendIP"
}

variable "http_setting_name" {
  description = "Name of the HTTP setting"
  type        = string
  default     = "appGatewayBackendHttpSettings"
}

variable "listener_name" {
  description = "Name of the listener"
  type        = string
  default     = "appGatewayHttpListener"
}

variable "request_routing_rule_name" {
  description = "Name of the request routing rule"
  type        = string
  default     = "rule1"
}

variable "redirect_configuration_name" {
  description = "Name of the redirect configuration"
  type        = string
  default     = "appGatewayRedirectConfig"
}

variable "backend_fqdns" {
  description = "Backend FQDNs for the application gateway"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
