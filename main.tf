########################## Logic ##########################
#
# Define local variables to create internal logic.
# Often used for adding standard and custom Tag values.
#
###########################################################
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = merge(var.tags, local.module_tag)
}


####################### Azure vNET ########################
#
# Creates a new vNET in the specified Resource Group.
#
###########################################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet.cidr
  dns_servers         = var.dns_servers
  tags                = local.tags
}


###################### Azure Subnets ######################
#
# Create Subnets in the new vNet.
# NSG must be created with standard subnets
# Options to associate with Route Tables.
# Special subnets can be created without NSG (EG, Bastion)
#
###########################################################
resource "azurerm_subnet" "subnet" {
  for_each                                       = var.subnets
  name                                           = each.key
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value.cidr_prefix
  service_endpoints                              = lookup(var.subnet_service_endpoints, each.key, null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_enforce_private_link_endpoint_network_policies, each.key, false)
  enforce_private_link_service_network_policies  = lookup(var.subnet_enforce_private_link_service_network_policies, each.key, false)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []

    content {
      name = lookup(each.value.delegation, "name", null)

      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}


# Subnet Network Security Group
resource "azurerm_network_security_group" "subnet_nsg" {

  for_each            = var.subnets
  name                = each.value.nsg_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags

  dynamic "security_rule" {
    for_each = lookup(each.value, "rules", [])
    content {
      name                                       = lookup(security_rule.value, "name", null)
      priority                                   = lookup(security_rule.value, "priority", null)
      direction                                  = lookup(security_rule.value, "direction", null)
      access                                     = lookup(security_rule.value, "access", null)
      protocol                                   = lookup(security_rule.value, "protocol", null)
      source_port_range                          = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges                         = lookup(security_rule.value, "source_port_ranges", null)
      destination_port_range                     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges                    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix                      = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes                    = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix                 = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes               = lookup(security_rule.value, "destination_address_prefixes", null)
      source_application_security_group_ids      = lookup(security_rule.value, "source_application_security_group_ids ", null)
      destination_application_security_group_ids = lookup(security_rule.value, "destination_application_security_group_ids ", null)
    }
  }
}

# Subnet Associations
locals {
  azurerm_subnets = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }

  subnet_map = azurerm_subnet.subnet
  nsg_object = azurerm_network_security_group.subnet_nsg
}

/*
resource "azurerm_subnet_route_table_association" "standard_subnet_route_table" {
  for_each = local.azurerm_subnets
  
  subnet_id      = each.value
  route_table_id = var.route_table_id
}
*/

resource "azurerm_subnet_network_security_group_association" "nsg_vnet_association" {
  for_each = local.subnet_map

  subnet_id                 = local.subnet_map[each.key].id
  network_security_group_id = local.nsg_object[each.key].id
}


## Special Subnet
resource "azurerm_subnet" "special" {
  for_each = var.special_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.cidr_prefix
  service_endpoints    = lookup(var.subnet_service_endpoints, each.key, null)
}



# Logging and Analytics to be added in future release
###################### Network Logging ######################
#
# Define diagnostic settings and network watcher services.
#
###########################################################