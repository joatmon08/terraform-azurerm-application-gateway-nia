resource "azurerm_resource_group" "test" {
  name     = var.name
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = var.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags                = var.tags
}

resource "azurerm_subnet" "test" {
  name                 = var.name
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "test" {
  name                = var.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "Egress"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Inbound access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "8300", "8301", "8500", "9090", "9091"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "SSH, Consul, application ingress traffic"
  }


  tags = var.tags
  timeouts {}
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
  depends_on                = [azurerm_subnet.test]
}
