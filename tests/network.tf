locals {
  service_port                   = 9090
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_resource_group" "test" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "test" {
  name                = var.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.254.0.0/16"]
  tags                = var.tags
}

resource "azurerm_public_ip" "test" {
  name                = var.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = var.sku_tier == "Standard" ? "Dynamic" : "Static"
  sku                 = var.sku_tier == "Standard" ? "Basic" : "Standard"
  tags                = var.tags
}

resource "azurerm_subnet" "test" {
  name                 = var.name
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.254.0.0/24"]
}

module "gateway" {
  source                          = "./.."
  name                            = var.name
  azurerm_resource_group_name     = azurerm_resource_group.test.name
  azurerm_resource_group_location = azurerm_resource_group.test.location
  azurerm_service_subnet_id       = azurerm_subnet.test.id
  azurerm_public_ip_id            = azurerm_public_ip.test.id
  ssl_certificates                = local.ssl_certificates
  custom_error_configurations     = var.custom_error_configurations
  services                        = var.services
  enable_path_based_routing       = var.enable_path_based_routing
  frontend_port                   = var.frontend_port
  sku_name                        = var.sku_name
  sku_tier                        = var.sku_tier
  backend_certificates            = var.backend_certificates
}
