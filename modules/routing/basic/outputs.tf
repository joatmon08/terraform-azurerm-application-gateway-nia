output "request_routing_rule" {
  value = [for service, hostnames in var.basic_routing : {
    name                       = service
    rule_type                  = "Basic"
    http_listener_name         = service
    backend_address_pool_name  = service
    backend_http_settings_name = service
    url_path_map_name          = null
  }]
}

output "http_listener" {
  value = [for service, hostnames in var.basic_routing : {
    name                           = service
    frontend_ip_configuration_name = var.name
    frontend_port_name             = var.name
    protocol                       = contains(keys(var.ssl_certificate_names), service) ? "Https" : "Http"
    ssl_certificate_name           = lookup(var.ssl_certificate_names, service, null)
    custom_error_configuration     = contains(keys(var.custom_error_configurations), service) ? [var.custom_error_configurations[service]] : []
    host_name                      = length(hostnames) == 1 ? one(hostnames) : null
    host_names                     = length(hostnames) > 1 ? hostnames : null
  }]
}

output "url_path_map" {
  value = []
}
