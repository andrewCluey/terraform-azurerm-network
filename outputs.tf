output "subnet_id_map" {
  description = "description"
  value       = azurerm_subnet.subnet
}

output "nsg_object" {
  description = "description"
  value       = azurerm_network_security_group.subnet_nsg
}

output "subnet_name_id" {
  description = "subnet name:id"
  value       = local.azurerm_subnets
}
