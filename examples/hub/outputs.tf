output "subnet_name_id" {
  description = "A map of Subnet name : id"
  value       = module.vnet.subnet_name_id
}

output "vnet_id" {
  description = "The ID of the new vNET"
  value       = module.vnet.vnet_id
}
