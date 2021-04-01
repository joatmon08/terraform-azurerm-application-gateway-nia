output "consul_token" {
  value     = random_uuid.consul_bootstrap_token.result
  sensitive = true
}