data "azurerm_network_interface" "sli" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "master-0-sli"
  resource_group_name = format("%s-volt",azurerm_resource_group.main.name)
}

resource "azurerm_route_table" "inspect_external" {
  name                          = "${var.name}_external_rt"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "ext_within_vnet" {
  name                   = "within-vnet"
  resource_group_name    = azurerm_resource_group.main.name
  route_table_name       = azurerm_route_table.inspect_external.name
  address_prefix         = azurerm_virtual_network.main.address_space[0]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.azurerm_network_interface.sli.private_ip_address
}

resource "azurerm_route" "ext_within_subnet" {
  name                = "within-subnet"
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.inspect_external.name
  address_prefix      = azurerm_subnet.inspect_external.address_prefixes[0]
  next_hop_type       = "VnetLocal"
}

resource "azurerm_route" "ext_default" {
  name                = "default-nva"
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.inspect_external.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VnetLocal"
}

resource "azurerm_subnet_route_table_association" "inspect_ext_associate" {
  subnet_id      = azurerm_subnet.inspect_external.id
  route_table_id = azurerm_route_table.inspect_external.id
}