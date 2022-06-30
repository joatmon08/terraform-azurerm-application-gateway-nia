terraform {
  required_version = "~> 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.33"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.25"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "hcp" {}