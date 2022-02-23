terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.3"
    }
  }
}

locals {
  tags = merge(var.tags,{})

  azure_subnet_config = {
    "mgmt" = {
      cidr = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,0)]
    },
    "external" = {
      cidr = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,1)]
    },
    "internal" = {
      cidr = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,2)]
    },
    "inspect_external" = {
      cidr = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,3)]
    },
    "inspect_internal" = {
      cidr = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,4)]
    },
    "application" = {
      cidr = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,10)]
    },
}

}



variable location{
    type = string
}

