data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.name}_main_rg"
  location = var.location
  tags     = local.tags
}
variable cidr {
    type = string
    default = "10.0.0.0/16"
}
# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-network"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet" "this" {
  for_each             = local.azure_subnet_config
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = each.value.cidr
}