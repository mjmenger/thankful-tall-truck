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

  trusted_cidrs = concat(var.trusted_cidrs,[azurerm_virtual_network.main.address_space[0]])

}

variable trusted_cidrs {
  type = list(string)
  default = []
}

output trusted_cidrs {
  value = local.trusted_cidrs
}


variable location{
  type = string
}
variable deploy_applications {
  type    = bool
  default = false
}
variable application_namespace {
  type = string
  default = ""
}
variable delegated_domain {
  type = string
  description = "if applications are being deployed what domain do we use"
}
