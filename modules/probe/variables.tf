variable "cts_attributes" {
  type        = map(map(string))
  description = "All CTS user-defined metadata, indexed by service name"
}
