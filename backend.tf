terraform {
  # Temporarily using local backend - remote storage account was deleted
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-payg-rg"
  #   storage_account_name = "tfstatepayg250254"
  #   container_name       = "tfstate"
  #   key                  = "webapp-infra.tfstate"
  # }
}
