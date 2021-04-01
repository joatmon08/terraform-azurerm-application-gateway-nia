output "configuration" {
  value = { for service, attributes in var.cts_attributes : service => {
    port                  = one(var.service_ports[service])
    path                  = lookup(attributes, "backend_path", null)
    cookie_based_affinity = lookup(attributes, "backend_cookie_based_affinity", "Disabled")
    request_timeout       = lookup(attributes, "backend_request_timeout", 60)
    }
  }
}
