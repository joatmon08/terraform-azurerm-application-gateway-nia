variable "cts_attributes" {
  type        = map(map(string))
  description = "All CTS user-defined metadata, indexed by service name."
}

variable "service_ports" {
  type        = map(list(number))
  description = "Service ports to use, indexed by service name."
}
