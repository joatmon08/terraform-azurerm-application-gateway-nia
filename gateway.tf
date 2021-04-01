module "custom_probes" {
  source         = "./modules/probe"
  cts_attributes = local.cts_attributes
}

module "backend_http_settings" {
  source         = "./modules/backend_http_settings"
  cts_attributes = local.cts_attributes
  service_ports  = local.service_ports
}

module "basic" {
  count                       = var.enable_path_based_routing ? 0 : 1
  source                      = "./modules/routing/basic"
  name                        = var.name
  ssl_certificate_names       = { for name, cert in var.ssl_certificates : name => cert.name }
  custom_error_configurations = var.custom_error_configurations
  default_backend_service     = local.default_backend_service
  basic_routing               = local.basic_routing_host_names_v2 == {} ? local.basic_routing_host_name : local.basic_routing_host_names_v2
}

module "path_based" {
  count                       = var.enable_path_based_routing ? 1 : 0
  source                      = "./modules/routing/path_based"
  name                        = var.name
  ssl_certificate_name        = length(var.ssl_certificates) > 0 ? var.ssl_certificates[one(keys(var.ssl_certificates))].name : null
  custom_error_configurations = var.custom_error_configurations
  default_backend_service     = local.default_backend_service
  path_based_routing          = local.path_based_routing
}

locals {
  module                = var.enable_path_based_routing ? one(module.path_based) : one(module.basic)
  request_routing_rules = local.module.request_routing_rule
  http_listeners        = local.module.http_listener
  url_path_map          = local.module.url_path_map
}

resource "azurerm_application_gateway" "service" {
  name                = var.name
  resource_group_name = var.azurerm_resource_group_name
  location            = var.azurerm_resource_group_location
  zones               = var.zones
  tags                = var.tags
  enable_http2        = var.enable_http2
  firewall_policy_id  = var.firewall_policy_id

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration
    content {
      min_capacity = autoscale_configuration.min
      max_capacity = autoscale_configuration.max
    }
  }

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = length(var.autoscale_configuration) == 0 ? var.sku_capacity : null
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [0] : []
    content {
      identity_ids = var.identity_ids
    }
  }

  gateway_ip_configuration {
    name      = var.name
    subnet_id = var.azurerm_service_subnet_id
  }

  frontend_port {
    name = var.name
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                            = var.name
    public_ip_address_id            = var.azurerm_public_ip_id
    private_ip_address              = var.azurerm_private_ip_address
    private_ip_address_allocation   = var.private_ip_address_allocation
    subnet_id                       = var.azurerm_private_ip_address != null ? var.azurerm_service_subnet_id : null
    private_link_configuration_name = length(var.private_link_ip_configurations) > 0 ? var.name : null
  }

  dynamic "private_link_configuration" {
    for_each = length(var.private_link_ip_configurations) > 0 ? [0] : []
    content {
      name = var.name
      dynamic "ip_configuration" {
        for_each = var.private_link_ip_configurations
        content {
          name                          = private_link_configuration.value.name
          subnet_id                     = private_link_configuration.value.subnet_id
          private_ip_address_allocation = private_link_configuration.value.private_ip_address_allocation
          primary                       = private_link_configuration.value.primary
          private_ip_address            = private_link_configuration.value.private_ip_address
        }
      }
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.data
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = local.backend_trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = base64decode(trusted_root_certificate.value.data)
    }
  }

  dynamic "authentication_certificate" {
    for_each = local.backend_authentication_certificates
    content {
      name = authentication_certificate.value.name
      data = base64decode(authentication_certificate.value.data)
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.service_ip_addresses
    content {
      name         = backend_address_pool.key
      ip_addresses = backend_address_pool.value
    }
  }

  dynamic "backend_http_settings" {
    for_each = module.backend_http_settings.configuration
    content {
      name                                = backend_http_settings.key
      probe_name                          = contains(keys(module.custom_probes.configuration), backend_http_settings.key) ? backend_http_settings.key : null
      pick_host_name_from_backend_address = contains(keys(module.custom_probes.configuration), backend_http_settings.key)
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = backend_http_settings.value.port
      path                                = backend_http_settings.value.path
      protocol                            = lookup(local.backend_protocol, backend_http_settings.key, "Http")
      request_timeout                     = backend_http_settings.value.request_timeout
      trusted_root_certificate_names      = lookup(local.backend_trusted_root_certificates_names, backend_http_settings.key, null)

      dynamic "authentication_certificate" {
        for_each = lookup(local.backend_authentication_certificate_names, backend_http_settings.key, [])
        content {
          name = authentication_certificate.value
        }
      }
    }
  }

  dynamic "probe" {
    for_each = module.custom_probes.configuration
    content {
      name                                      = probe.key
      pick_host_name_from_backend_http_settings = true
      interval                                  = probe.value.interval
      protocol                                  = lookup(local.backend_protocol, probe.key, "Http")
      path                                      = probe.value.path
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      dynamic "match" {
        for_each = probe.value.match_body != null ? [0] : []
        content {
          body = probe.value.match_body
        }
      }

      dynamic "match" {
        for_each = length(probe.value.match_status_code) > 0 ? [0] : []
        content {
          status_code = probe.value.match_status_code
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      url_path_map_name          = request_routing_rule.value.url_path_map_name
    }
  }

  dynamic "http_listener" {
    for_each = local.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      host_name                      = http_listener.value.host_name
      host_names                     = http_listener.value.host_names
      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configuration
        content {
          status_code           = custom_error_configuration.value.status_code
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
        }
      }
    }
  }

  dynamic "url_path_map" {
    for_each = local.url_path_map
    content {
      name                               = url_path_map.value.name
      default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name
      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules
        content {
          name                       = path_rule.value.name
          paths                      = path_rule.value.paths
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
        }
      }
    }
  }
}
