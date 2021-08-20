output "subnet_id_map" {
  description = "description"
  value       = module.vnet.subnet_id_map
}

output "nsg_object" {
  description = "description"
  value       = module.vnet.nsg_object
}

output "vnet_id" {
  description = "The ID of the new vNET"
  value       = module.vnet.vnet_id
}
