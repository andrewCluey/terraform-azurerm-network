### Deploy core dependencies
resource "azurerm_resource_group" "rg" {
  name     = "rg-dev-network"
  location = "uksouth"
}

### Deploy Networking Module for Testing

module "vnet" {
  source              = "../../"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg.name

  vnet = {
    name = "Test-vNet"
    cidr = ["10.1.0.0/16"]
  }

  special_subnets = {
    AzureFirewallSubnet = {
      cidr_prefix       = ["10.1.2.0/26"]
      service_endpoints = []
    }
  }

  subnets = {
    private = {
      cidr_prefix = ["10.1.0.0/24"]
      nsg_name    = "Subnet1Default" # All subnets require an NSG; not necessary to add rules.

      # Optional Service Delegation - See Microsoft Documentation for all available delegations.
      delegation = {
        name = "acctestdelegation1"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
      }
    },
    public = {
      cidr_prefix = ["10.1.1.0/24"]
      nsg_name    = "Subnet2Default"
      rules = [
        {
          name                       = "https",
          priority                   = "100"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
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
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }

  }

}