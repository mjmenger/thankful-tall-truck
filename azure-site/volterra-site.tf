

variable volterra_token {
    type = string
}
variable name {
    type = string
    description = "a common name prefix"
}
variable tags {
    type = map(string)
    default = {}
}
variable azure_client_id{}
variable azure_subscription_id{}
variable azure_tenant_id{}
variable azure_client_secret{}

resource "volterra_cloud_credentials" "azure_site" {
  name      = format("%s-azure-credentials", var.name)
  namespace = "system"
  labels    = var.tags
  azure_client_secret {
    client_id       = var.azure_client_id
    subscription_id = var.azure_subscription_id
    tenant_id       = var.azure_tenant_id
    client_secret {
      clear_secret_info {
        url = "string:///${base64encode(var.azure_client_secret)}"
      }
    }

  }
}
resource "volterra_tf_params_action" "action_test" {
  site_name       = volterra_azure_vnet_site.azure_site.name
  site_kind       = "azure_vnet_site"
  action          = "apply"
  wait_for_action = true
}
variable public_key {}
resource "volterra_azure_vnet_site" "azure_site" {
  name      = format("%s-vnet-site", var.name)
  namespace = "system"
  labels    = var.tags

  azure_region   = var.location
  resource_group = format("%s-volt",azurerm_resource_group.main.name)
  ssh_key        = var.public_key

  machine_type = "Standard_D3_v2"

  # commenting out the co-ordinates because of below issue
  # https://github.com/volterraedge/terraform-provider-volterra/issues/61
  #coordinates {
  #  latitude  = "43.653"
  #  longitude = "-79.383"
  #}

  #assisted = true
  azure_cred {
    name      = volterra_cloud_credentials.azure_site.name
    namespace = "system"
  }

  # new error when no worker nodes?
  # nodes_per_az = 1
  no_worker_nodes = true
  # worker_nodes = 0

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true

  vnet {

    existing_vnet {
      resource_group = azurerm_resource_group.main.name
      vnet_name      = azurerm_virtual_network.main.name
    }

  }

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"
    // azure-byol-multi-nic-voltmesh

    no_forward_proxy  = true
    no_global_network = true
    #no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    inside_static_routes {
      static_route_list {
        custom_static_route {
          attrs = [
            "ROUTE_ATTR_INSTALL_HOST",
            "ROUTE_ATTR_INSTALL_FORWARDING"
          ]
          subnets {
            ipv4 {
              prefix = "10.90.0.0"
              plen   = 16
            }
          }
          nexthop {
            type = "NEXT_HOP_USE_CONFIGURED"
            nexthop_address {
              ipv4 {
                addr = "10.90.2.1"
              }
            }
            interface {
              namespace = "system"
              name      = "ves-io-azure-vnet-site-${format("%s-vnet-site", var.name)}-inside"
            }
          }
        }
        custom_static_route {
          attrs = [
            "ROUTE_ATTR_INSTALL_HOST",
            "ROUTE_ATTR_INSTALL_FORWARDING"
          ]
          subnets {
            ipv4 {
              prefix = "0.0.0.0"
              plen   = 0
            }
          }
          nexthop {
            type = "NEXT_HOP_NETWORK_INTERFACE"
            nexthop_address {
              ipv4 {
                addr = ""
              }
            }
            interface {
              namespace = "system"
              name      = "ves-io-azure-vnet-site-${format("%s-vnet-site", var.name)}-inside"
            }
          }
        }
      }
    }

    az_nodes {
      azure_az = "1"

      outside_subnet {
        subnet {
          subnet_resource_grp = azurerm_resource_group.main.name
          vnet_resource_group = true
          subnet_name         = azurerm_subnet.this["external"].name # azurerm_subnet.external.name
        }
      }

      inside_subnet {
        subnet {
          subnet_resource_grp = azurerm_resource_group.main.name
          vnet_resource_group = true
          subnet_name         = azurerm_subnet.this["internal"].name # azurerm_subnet.internal.name
        }
      }

    }

  }

}