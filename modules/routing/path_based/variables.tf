variable "name" {
  type        = string
  description = "The name for resources specific to testing this module"
}

variable "ssl_certificate_name" {
  type        = string
  description = "Name of SSL certificate to attach to listener"
  default     = null
}

variable "custom_error_configurations" {
  type = map(object({
    status_code           = string
    custom_error_page_url = string
  }))
  description = "Custom error configurations to attach to listeners"
  default     = {}
}

variable "default_backend_service" {
  type        = string
  description = "Name of the default backend service for URL map"
}

variable "path_based_routing" {
  type        = map(list(string))
  description = "List of services and their paths"
}
