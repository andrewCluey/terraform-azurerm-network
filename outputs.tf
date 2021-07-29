output "subnet_id_map" {
  description = "description"
  value       = azurerm_subnet.subnet
}

output "nsg_object" {
  description = "description"
  value       = azurerm_network_security_group.subnet_nsg
}