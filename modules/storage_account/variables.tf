variable "storage_account_name" {
  description = "The name of the Storage Account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the storage account"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "The subnet ID where the private endpoint will be created"
  type        = string
}