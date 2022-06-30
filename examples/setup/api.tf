resource "azurerm_network_interface" "api" {
  depends_on = [
    azurerm_subnet_network_security_group_association.test
  ]
  name                = "${var.name}-api"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "api" {
  depends_on          = [azurerm_linux_virtual_machine.consul]
  name                = "${var.name}-api"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags                = var.tags
  size                = "Standard_F2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.api.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("scripts/api.sh", {
    USE_HCP            = var.use_hcp
    CONSUL_SERVER      = replace(local.consul_address, "https://", "")
    CONSUL_DATACENTER  = local.consul_datacenter
    GOSSIP_KEY         = local.gossip_key
    CA_PUBLIC_KEY      = local.consul_ca_public_key
    CLIENT_PUBLIC_KEY  = tls_locally_signed_cert.client_api_signed_cert.cert_pem
    CLIENT_PRIVATE_KEY = tls_private_key.client_api_key.private_key_pem
    BOOTSTRAP_TOKEN    = local.consul_token
    CONSUL_VERSION     = var.consul_version
    ENVOY_VERSION      = var.envoy_version
  }))
}

## uncomment as an example of a second API service instance

resource "azurerm_network_interface" "api_2" {
  name                = "${var.name}-api-2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "api_2" {
  name                = "${var.name}-api-2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags                = var.tags
  size                = "Standard_F2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.api_2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("scripts/api.sh", {
    USE_HCP            = var.use_hcp
    CONSUL_SERVER      = replace(local.consul_address, "https://", "")
    CONSUL_DATACENTER  = local.consul_datacenter
    GOSSIP_KEY         = local.gossip_key
    CA_PUBLIC_KEY      = local.consul_ca_public_key
    CLIENT_PUBLIC_KEY  = tls_locally_signed_cert.client_api_v2_signed_cert.cert_pem
    CLIENT_PRIVATE_KEY = tls_private_key.client_api_v2_key.private_key_pem
    BOOTSTRAP_TOKEN    = local.consul_token
    CONSUL_VERSION     = var.consul_version
    ENVOY_VERSION      = var.envoy_version
  }))
}
