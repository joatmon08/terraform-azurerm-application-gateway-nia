output "configuration" {
  value = { for service, attributes in var.cts_attributes : service => {
    interval            = lookup(attributes, "probe_interval", 60)
    path                = lookup(attributes, "probe_path", "/")
    timeout             = lookup(attributes, "probe_timeout", 60)
    unhealthy_threshold = lookup(attributes, "probe_unhealthy_threshold", 3)
    match_body          = lookup(attributes, "probe_match_body", null)
    match_status_code   = jsondecode(lookup(attributes, "probe_match_status_code", "[]"))
    } if lookup(attributes, "probe_enable", false)
  }
}
