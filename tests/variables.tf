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
    Purpose = "Module testing for terraform-azurerm-application-gateway-nia"
  }
}

variable "enable_path_based_routing" {
  type        = bool
  description = "Enable `PathBasedRouting` for HTTP listeners and backend address pools. Otherwise, default to `Basic`."
  default     = false
}

variable "ssl_certificates" {
  type = map(object({
    name                = string
    data_file_path      = string
    password            = string
    key_vault_secret_id = string
  }))
  description = "SSL certificates for application gateway"
  default     = {}
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "sku_name" {
  type        = string
  description = "The name of SKU for application gateway."
  default     = "Standard_v2"
}

variable "sku_tier" {
  type        = string
  description = "The tier of SKU"
  default     = "Standard_v2"
}

variable "backend_certificates" {
  type = map(list(object({
    name = string
    data = string
  })))
  description = "Authentication and trusted root (SKU v2) certificates for each backend_http_setting on application gateway, indexed by service name."
  default     = {}
}

variable "custom_error_configurations" {
  description = "Custom error configuration"
  type = map(object({
    status_code           = string
    custom_error_page_url = string
  }))
  default = {}
}

locals {
  ssl_certificates = { for service, cert in var.ssl_certificates : service => {
    name                = cert.name,
    data                = filebase64(cert.data_file_path)
    password            = cert.password
    key_vault_secret_id = cert.key_vault_secret_id
  } }
}

variable "services" {
  description = "Consul services monitored by Consul-Terraform-Sync"
  type = map(
    object({
      id        = string
      name      = string
      kind      = string
      address   = string
      port      = number
      meta      = map(string)
      tags      = list(string)
      namespace = string
      status    = string

      node                  = string
      node_id               = string
      node_address          = string
      node_datacenter       = string
      node_tagged_addresses = map(string)
      node_meta             = map(string)

      cts_user_defined_meta = map(string)
    })
  )
}
