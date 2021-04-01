output "azurerm_application_gateway_id" {
  description = "The ID of the Azure application gateway"
  value       = azurerm_application_gateway.service.id
}