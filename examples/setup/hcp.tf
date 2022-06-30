locals {
  consul_address        = var.use_hcp ? hcp_consul_cluster.test.0.consul_private_endpoint_url : azurerm_linux_virtual_machine.consul.0.private_ip_address
  consul_token          = var.use_hcp ? hcp_consul_cluster.test.0.consul_root_token_secret_id : random_uuid.consul_bootstrap_token.0.result
  consul_datacenter     = var.use_hcp ? hcp_consul_cluster.test.0.datacenter : "dc1"
  consul_ca_public_key  = var.use_hcp ? base64decode(hcp_consul_cluster.test.0.consul_ca_file) : tls_self_signed_cert.ca_cert.cert_pem
  gossip_key            = var.use_hcp ? jsondecode(base64decode(hcp_consul_cluster.test.0.consul_config_file))["encrypt"] : random_id.gossip_key.0.b64_std
  consul_public_address = var.use_hcp ? hcp_consul_cluster.test.0.consul_public_endpoint_url : "http://${azurerm_linux_virtual_machine.consul.0.public_ip_address}:8500"
}

data "azurerm_subscription" "current" {}

## Create HCP resources.

resource "hcp_hvn" "test" {
  count          = var.use_hcp ? 1 : 0
  hvn_id         = var.name
  cloud_provider = "azure"
  region         = azurerm_resource_group.test.location
  cidr_block     = "172.25.16.0/20"
}

module "hcp_peering" {
  count   = var.use_hcp ? 1 : 0
  source  = "hashicorp/hcp-consul/azurerm"
  version = "~> 0.2.0"

  # Required
  tenant_id       = data.azurerm_subscription.current.tenant_id
  subscription_id = data.azurerm_subscription.current.subscription_id
  hvn             = hcp_hvn.test.0
  vnet_rg         = azurerm_virtual_network.test.resource_group_name
  vnet_id         = azurerm_virtual_network.test.id
  subnet_ids      = [azurerm_subnet.test.id]

  prefix = var.name
}

resource "hcp_consul_cluster" "test" {
  count           = var.use_hcp ? 1 : 0
  cluster_id      = var.name
  hvn_id          = hcp_hvn.test.0.hvn_id
  public_endpoint = true
  tier            = "development"
}