terraform {
  required_version = ">= 1.8.0" # provider-defined functions (provider::azurerm::parse_resource_id)
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.3.0"
    }
  }
}
