variable "location" {
  type        = string
  description = " The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created."
}

variable "name" {
  type        = string
  description = "The name for resources specific to testing this module"
}

variable "tags" {
  type        = map(string)
  description = "Tags for all testing resources in module"
  default = {
    Purpose = "E2E testing for terraform-azurerm-application-gateway-nia"
  }
}
