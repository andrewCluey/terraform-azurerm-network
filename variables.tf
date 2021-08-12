variable "location" {
  type        = string
  description = "The Azure region where the new Resources will be created."
  default     = "uksouth"
}


variable "resource_group_name" {
  type        = string
  description = "The name of the Resource group where the new Resources will be created."
}


variable "vnet" {
  type = object({
    name = string
    cidr = list(string)
  })
}


variable "dns_servers" {
  type        = list(string)
  description = "A list of DNS Servers (IP ADDRESSES) that the new vNET should use."
  default     = null
}


variable "tags" {
  description = "tags to apply to the new resources"
  type        = map(string)
  default     = null
}


variable "subnets" {
  description = <<EOD
  Object used to define the new Subnets to create (Requires an NSG). 
  EXAMPLE CONFIGURATION:
      subnets             = {
        subnet1 = {
            cidr_prefix = ["10.0.0.0/24"]
            delegation  = {
              name = "acctestdelegation1"
              service_delegation = {
                name    = "Microsoft.ContainerInstance/containerGroups"
                actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
                }
              }
            },
      subnet2 = {
        cidr_prefix = ["10.0.1.0/24"]
      }
    }
EOD
}



variable "special_subnets" {
  description = <<EOD
  Input parameter to be used when the Subnet is for special resources such as Bastion or Azure Firewall (where an NSG is not required.)
  EXAMPLE CONFIGURATION:
      special_subnets = {
        AzureFirewallSubnet = {
            cidr_prefix       = ["10.0.0.0/26"]
            service_endpoints = []
        }
      }
EOD
}


variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(any)
  default     = {}
}


variable "subnet_enforce_private_link_endpoint_network_policies" {
  description = "A map of subnet name to enable/disable private link endpoint network policies on the subnet. Defaults to FALSE"
  type        = map(bool)
  default     = {}
}


variable "subnet_enforce_private_link_service_network_policies" {
  description = "A map of subnet name to enable/disable private link service network policies on the subnet. Defaults to FALSE."
  type        = map(bool)
  default     = {}
}


variable "nsg_ids" {
  description = <<EOD
  A map of subnet names to Network Security Group IDs.
  EXAMPLE (Using interpolation to reference a new NSG created within the Terraform deployment):
    nsg_ids = {
        subnet1 = azurerm_network_security_group.nsg1.id
        subnet2 = azurerm_network_security_group.nsg2.id
    }
EOD
  type        = map(string)
  default     = {}
}


# Removed Route Table association. 
# Improved functionality to be aded in future release.
/*
variable "route_table_id" {
  type        = string
  description = "The ID of the default route table to assign to all 'standard' subnets."
}

variable "route_table_ids" {
  description = <<EOD
  A map of subnet name to Route table ids.
  EXAMPLE (existing Route Table IDs):
    route_table_ids = {
      subnet1 = "/subscriptions/7dghd-eewws-34ee2/resourceGroups/rg/providers/Microsoft.Network/routeTables/rt-default"
      subnet2 = "/subscriptions/7dghd-eewws-34ee2/resourceGroups/rg/providers/Microsoft.Network/routeTables/rt-default"
    }
EOD

  type    = map(string)
  default = {}
}
*/