variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The subnet ID where the SQL private endpoint will be created"
  type        = string
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for SQL Server"
  type        = bool
  default     = true
}

variable "storage_endpoint" {
  description = "Storage endpoint for SQL auditing logs (enables monthly audit log retention)"
  type        = string
  default     = ""
}

