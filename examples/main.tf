### Deploy core dependencies
resource "azurerm_resource_group" "vnet" {
  name     = "rg-dev-network"
  location = "uksouth"
}

resource "azurerm_route_table" "rt1" {
  name                = "ascdevrt1"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.vnet.name
}


### Deploy Networking Module for Testing

module "vnet" {
  source              = "../"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.vnet.name
  dns_servers         = ["10.10.10.53"]     # Optional. Will revert to Azure provided DNS servers if omitted. 
  
  vnet = {
    name = "Test-vNet"
    cidr = ["10.0.0.0/16"]
  }

  special_subnets = {
    AzureFirewallSubnet = {
      cidr_prefix = ["10.0.2.0/26"]
      service_endpoints = []
    }
  }

  subnets = {
    subnet1 = {
      cidr_prefix = ["10.0.0.0/24"]
      nsg_name    = "Subnet1Default"       # All subnets require an NSG; not necessary to add rules.
      
      # Optional Service Delegation - See Microsoft Documentation for all available delegations.
      delegation = {
        name = "acctestdelegation1"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
      }
    },
    subnet2 = {
      cidr_prefix = ["10.0.1.0/24"]
      nsg_name    = "Subnet2Default"
      rules = [
        {
          name                       = "https",
          priority                   = "100"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "TCP"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "CleanUp"
          priority                   = "400"
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "TCP"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }

  }

  route_table_ids = {
    subnet1 = azurerm_route_table.rt1.id
    subnet2 = azurerm_route_table.rt1.id
  }
}