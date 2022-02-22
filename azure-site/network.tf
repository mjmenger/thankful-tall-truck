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

# Create the Management Subnet within the Virtual Network
resource "azurerm_subnet" "mgmt" {
  name                 = "mgmt"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,0)]
}

# Create the external Subnet within the Virtual Network
resource "azurerm_subnet" "external" {
  name                 = "external"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,1)]
}

# Create the internal Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.main.address_space[0],8,2)]
}