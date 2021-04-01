variable "name" {
  type        = string
  description = "The name for resources specific to testing this module"
}

variable "ssl_certificate_names" {
  type        = map(string)
  description = "Names of SSL certificates to attach to listeners"
  default     = {}
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

variable "basic_routing" {
  type        = map(list(string))
  description = "List of services and their hostname(s) for routing"
}