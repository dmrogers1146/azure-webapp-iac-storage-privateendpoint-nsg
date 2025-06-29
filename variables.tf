# General Variables
variable "subscription_id" {
  description = "Azure subscription ID to deploy resources to"
  type        = string
  # No default - must be provided via environment-specific tfvars or workspace configuration
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-webapp-payg-demo" # Changed to avoid conflict
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West US 2"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Project     = "WebApp"
    ManagedBy   = "Terraform"
  }
}

# App Service Variables
variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "asp-webapp-demo"
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
  default     = "app-webapp-demo"
}

variable "app_service_sku" {
  description = "SKU of the App Service Plan"
  type        = string
  default     = "F1"
}

# SQL Database Variables
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
  default     = "sqlserver-webapp-demo"
}

variable "database_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "sqldb-webapp-demo"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  default     = "P@ssw0rd123!"
  sensitive   = true
}

# Storage Account Variables
variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
  default     = "stwebappdemo"
}

variable "storage_tier" {
  description = "Storage Account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication" {
  description = "Storage Account replication type"
  type        = string
  default     = "LRS"
}

# Application Gateway Variables
variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
  default     = "agw-webapp-demo"
}

# Key Vault Variables
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-webapp-demo"
}

variable "key_vault_base_name" {
  description = "Base name for the Key Vault (random suffix will be appended)"
  type        = string
  default     = "kv-webapp-demo"
}

# SQL Database Additional Variables
variable "sql_sku" {
  description = "SQL Database SKU"
  type        = string
  default     = "Basic"
}

# Application Gateway Additional Variables
variable "app_gateway_sku_name" {
  description = "Application Gateway SKU name"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_sku_tier" {
  description = "Application Gateway SKU tier"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_capacity" {
  description = "Application Gateway capacity"
  type        = number
  default     = 2
}

# Virtual Network Variables
variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-webapp-demo"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "environment_tags" {
  description = "Environment-specific tags"
  type        = map(string)
  default     = {}
}
