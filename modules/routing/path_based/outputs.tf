output "request_routing_rule" {
  value = [{
    name                       = var.name
    rule_type                  = "PathBasedRouting"
    http_listener_name         = var.name
    backend_address_pool_name  = null
    backend_http_settings_name = null
    url_path_map_name          = var.name
  }]
}

output "http_listener" {
  value = [{
    name                           = var.name
    frontend_ip_configuration_name = var.name
    frontend_port_name             = var.name
    protocol                       = var.ssl_certificate_name != null ? "Https" : "Http"
    ssl_certificate_name           = var.ssl_certificate_name
    custom_error_configuration     = values(var.custom_error_configurations)
    host_name                      = null
    host_names                     = null
  }]
}

output "url_path_map" {
  value = [{
    name                               = var.name
    default_backend_address_pool_name  = var.default_backend_service
    default_backend_http_settings_name = var.default_backend_service
    path_rules = [for service, path in var.path_based_routing : {
      name                       = service,
      paths                      = path,
      backend_address_pool_name  = service,
      backend_http_settings_name = service
    }]
  }]
}
