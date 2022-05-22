# Creates a virtual network with associated subnets, network security groups and analytics

Creates a virtual network with:
* Virtual network
* DNS Settings
* Subnet creation & delegation


### enforce_private_link_endpoint_network_policies

Network policies, like network security groups (NSG), are not supported for Private Link Endpoints or Private Link Services. In order to deploy a Private Link Endpoint on a given subnet, you must set the enforce_private_link_endpoint_network_policies attribute to true. This setting is only applicable for the Private Link Endpoint, for all other resources in the subnet access is controlled based via the Network Security Group which can be configured using the azurerm_subnet_network_security_group_association resource.

### input parameters
| input | type | optional | comment |
| -- | -- | -- | -- |
| location  | string | optional | if not set then default of 'uksouth' is set.  |
| resource_group_name | string | required |  |
| vnet | object | required | see table below |
| subnet | object | required | see table below |
| dns_servers | string | optional | IP Address of custom dns servers to assign to the new vNET. Default Azure servers used if not set. |
| subnet_service_endpoints | map | optional |  |
| subnet_enforce_private_link_endpoint_network_policies | map(bool) | optional | default value of false  |
| subnet_enforce_private_link_service_network_policies | map(bool) | optional | default value of false |
| nsg_ids | map(string) | optional | key:value pair of "subnetName" = "NSG_ID". Default will not assign a Network Security group to the new Subnets. |
| route_table_ids | map(string) | optional | key:value pair of "subnetName" = "RouteTable_ID". Default will retain default Azure Gateway, |
| tags | map | optional | A set of key:value pairs to tag the new resources. |


### vnet object

| input | type | optional | comment |
| -- | -- | -- | -- |
| name | string | mandatory | name of the virtul network to be created |
| cidr  | list | optional | address speace for the subnet |


```
    vnet = {
        name = "Test-vNet"
        cidr = ["10.0.0.0/16"]
    }
```

### subnet object

| input | type | optional | comment |
| -- | -- | -- | -- |
| cidr_prefix | string | mandatory | name of the virtul network to be created |
| delegation  | map | optional | address space for the subnet |
| service_endpoints | list | optional | |

```hcl
    subnets = {
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
```

### Example use

```hcl
module "network" {
  source  = "app.terraform.io/csx-demo/network/azurerm"
  version = "1.0.0"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.vnet.name
  dns_servers         = ["10.10.10.53"]     # Optional. Will revert to Azure provided DNS servers if omitted. 
  
  vnet = {
    name = "network"
    cidr = ["10.0.0.0/20"]
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
}

```


### future additions
* DDoS protection standard attachment
* Network Watcher Flow Logs and Traffic Analytics
* Diagnostics logging for the virtual network
* Diagnostics logging for the each sub-network
* Diagnostics logging for the network security groups