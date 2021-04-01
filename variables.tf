variable "name" {
  type        = string
  description = "The name for resources specific to testing this module."
}

variable "azurerm_resource_group_name" {
  type        = string
  description = "The name of the Azure resource group."
}

variable "azurerm_resource_group_location" {
  type        = string
  description = "The location of the Azure resource group."
}

variable "zones" {
  type        = list(string)
  description = "The collection of availability zones to spread the Application Gateway over. Only valid for SKU v2."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "The tags to assign to the application gateway."
  default     = {}
}

variable "enable_http2" {
  type        = bool
  description = "Enable HTTP2 on the application gateway. Default is `false`."
  default     = false
}

variable "firewall_policy_id" {
  type        = bool
  description = "The ID of the Web Application Firewall Policy."
  default     = null
}

// `sku` attributes.
variable "sku_name" {
  type        = string
  description = "The name of SKU for application gateway. Default is `Standard_v2`."
  default     = "Standard_v2"
}

variable "sku_tier" {
  type        = string
  description = "The tier of SKU for application gateway. Default is `Standard_v2`."
  default     = "Standard_v2"
}

variable "sku_capacity" {
  type        = number
  description = "The capacity of SKU for application gateway if you do not configure autoscaling. Default is `1`."
  default     = 1
}

variable "autoscale_configuration" {
  type = list(object({
    min = number
    max = number
  }))
  description = "The autoscaling configuration for SKU v2. Setting autoscale will override `sku_capacity`."
  default     = []
}

variable "azurerm_service_subnet_id" {
  type        = string
  description = "The ID of the Azure subnet hosting the application gateway. Used to configure `gateway_ip_configuration` and if applicable, private IP address for `frontend_ip_configuration`."
}

// `frontend_port` attributes.
variable "frontend_port" {
  type        = number
  description = "The frontend port for the Azure application gateway. Default is `80`."
  default     = 80
}

// `frontend_ip_configuration` attributes.
variable "azurerm_public_ip_id" {
  type        = string
  description = "The ID of the Azure public IP address to assign to application gateway. If using SKU v2, you must use a public IP with a `Static` allocation method and `Standard` SKU. Used to configure `frontend_ip_configuration`."
  default     = null
}

variable "azurerm_private_ip_address" {
  type        = string
  description = "The private IP address to assign to application gateway. Used to configure `frontend_ip_configuration`."
  default     = null
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`. Used to configure `frontend_ip_configuration`."
  default     = null
  validation {
    condition     = var.private_ip_address_allocation == "Dynamic" || var.private_ip_address_allocation == "Static" || var.private_ip_address_allocation == null
    error_message = "The private_ip_address_allocation must be `Dynamic` or `Static`."
  }
}

variable "identity_ids" {
  type        = list(string)
  description = "The list of single user managed identity IDs to be assigned to the application gateway. Used to configure `identity`."
  default     = []
}

variable "private_link_ip_configurations" {
  type = list(object({
    name                          = string
    subnet_id                     = string
    private_ip_address_allication = string
    primary                       = bool
    private_ip_address            = string
  }))
  description = "The IP configurations for private link configuration. Used to configure `frontend_ip_configuration` and `private_link_configuration`."
  default     = []
}

variable "ssl_certificates" {
  type = map(object({
    name                = string
    data                = string
    password            = string
    key_vault_secret_id = string
  }))
  description = "The SSL certificates for each HTTP listener on the application gateway, indexed by service name. Used to configure `ssl_certificate` and `http_listener`."
  default     = {}
}

variable "custom_error_configurations" {
  description = "The custom error configuration for each backend service, indexed by service name. Used to configure `custom_error_configuration` and `http_listener`."
  type = map(object({
    status_code           = string
    custom_error_page_url = string
  }))
  default = {}
}

variable "backend_certificates" {
  type = map(list(object({
    name = string
    data = string
  })))
  description = "The authentication (SKU v1) or trusted root (SKU v2) certificates for each backend service, indexed by service name. Used to configure `backend_http_settings`."
  default     = {}
}

variable "enable_path_based_routing" {
  type        = bool
  description = "Enable `PathBasedRouting` for HTTP listeners and backend address pools. Otherwise, default to `Basic` routing. Used to configure `request_routing_rule`."
  default     = false
}

variable "url_path_map_default_backend" {
  type        = string
  description = "The default service name for a URL path map when using path-based routing. Otherwise, default to first service listed. Used to configure `url_path_map`."
  default     = null
}

variable "services" {
  description = "The Consul services monitored by Consul-Terraform-Sync"
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

// Merge preset module tags with additional ones
locals {
  tags = merge(var.tags, {
    Module  = "terraform-azurerm-application-gateway-nia"
    Purpose = "Consul-Terraform-Sync"
  })
}

// Get service names, IP addresses, ports, and other CTS user-defined metadata for
// `backend_address_pool` and `backend_http_settings` transformations from CTS service variable.
locals {
  uses_sku_v2 = (var.sku_tier == "Standard_v2" || var.sku_tier == "WAF_v2")
  service_names = [
    for name, attributes in var.services : attributes.name
  ]
  service_ip_addresses = {
    for id, attributes in var.services : attributes.name => attributes.address...
  }
  service_ports = {
    for name, port in { for id, attributes in var.services : attributes.name => attributes.port... } : name => distinct(port)
  }
  cts_attributes = {
    for name, attributes in {
      for id, service in var.services : service.name => service.cts_user_defined_meta...
    } : name => merge(attributes...)
  }
}

// Generate backend certificates based on SKU version for `backend_http_settings`.
locals {
  backend_trusted_root_certificates   = var.backend_certificates != {} && local.uses_sku_v2 ? flatten(values(var.backend_certificates)) : []
  backend_authentication_certificates = var.backend_certificates != {} && !local.uses_sku_v2 ? flatten(values(var.backend_certificates)) : []
  backend_trusted_root_certificates_names = {
    for name, certs in var.backend_certificates : name => [for cert in certs : cert.name] if local.uses_sku_v2
  }
  backend_authentication_certificate_names = {
    for name, certs in var.backend_certificates : name => [for cert in certs : cert.name] if !local.uses_sku_v2
  }
  backend_protocol = {
    for name, cert in var.backend_certificates : name => "Https"
  }
}

// Generate basic routing configuration by aggregating hostnames.
locals {
  basic_routing_host_name = {
    for name, hosts in {
      for id, attributes in var.services : attributes.name => attributes.cts_user_defined_meta.host_name... if contains(keys(attributes.cts_user_defined_meta), "host_name")
    } : name => distinct(hosts)
  }
  basic_routing_host_names_v2 = {
    for name, hosts in {
      for id, attributes in var.services : attributes.name => jsondecode(attributes.cts_user_defined_meta.host_names)... if contains(keys(attributes.cts_user_defined_meta), "host_names") && local.uses_sku_v2
    } : name => distinct(flatten(hosts))
  }
}

// Generate basic routing configuration by aggregating paths.
locals {
  path_based_routing = {
    for name, path in {
      for id, attributes in var.services : attributes.name => attributes.cts_user_defined_meta.path... if contains(keys(attributes.cts_user_defined_meta), "path")
    } : name => distinct(path)
  }
  default_backend_service = var.enable_path_based_routing && var.url_path_map_default_backend == null ? keys(local.path_based_routing).0 : var.url_path_map_default_backend
}
