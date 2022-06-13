

# network interface for app vm
resource "azurerm_network_interface" "app" {
    count               = var.deploy_applications ? 1 : 0
    name                = format("%s-app-nic",var.name)
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "primary"
        subnet_id                     = azurerm_subnet.this["application"].id
        private_ip_address_allocation = "Dynamic"
        primary                       = true
        public_ip_address_id    = azurerm_public_ip.app[0].id
    }

    tags = merge(local.tags,{})
}
resource "azurerm_network_interface_security_group_association" "app-nsg" {
  network_interface_id      = azurerm_network_interface.app[0].id
  network_security_group_id = azurerm_network_security_group.app[0].id
}

resource azurerm_public_ip app {
    count               = var.deploy_applications ? 1 : 0
    name                = format("%s-app-public-ip",var.name)
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Static" # Static is required due to the use of the Standard sku
    sku                 = "Standard" # the Standard sku is required due to the use of availability zones
    availability_zone   = 1
    tags                = merge(local.tags,{})
}

resource "azurerm_linux_virtual_machine" "juiceshop" {
    count                 = var.deploy_applications ? 1 : 0
    name                  = format("%s-app-host-%02d",var.name, count.index)
    resource_group_name   = azurerm_resource_group.main.name
    location              = azurerm_resource_group.main.location
    size                  = "Standard_F2"
    admin_username        = "adminuser"

    custom_data    = base64encode( <<-EOF
#!/bin/bash
apt-get update -y;
apt-get install -y docker.io;
sysctl -w vm.max_map_count=262144
#permissions
usermod -aG docker $USER
usermod -aG docker adminuser
# enable syslog
echo "module(load=\"imtcp\")" >> /etc/rsyslog.conf
echo "input(type=\"imtcp\" port=\"1514\")" >> /etc/rsyslog.conf
echo "module(load=\"imudp\")" >> /etc/rsyslog.conf
echo "input(type=\"imudp\" port=\"1514\")" >> /etc/rsyslog.conf
systemctl restart rsyslog
# demo app
docker run -d -p 443:443 -p 80:80 --restart unless-stopped -e F5DEMO_APP=website \
 -e F5DEMO_NODENAME='F5 Azure' -e F5DEMO_COLOR=ffd734 -e F5DEMO_NODENAME_SSL='F5 Azure (SSL)' \
 -e F5DEMO_COLOR_SSL=a0bf37 chen23/f5-demo-app:ssl;
# juice shop
docker run -d --restart always -p 3000:3000 --name juiceshop bkimminich/juice-shop
EOF
    )

    network_interface_ids = [
        azurerm_network_interface.app[count.index].id,
    ]

    admin_ssh_key {
        username   = "adminuser"
        public_key = var.public_key
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-lts"
        version   = "latest"
    }

    tags = merge(local.tags,{})
}


resource "volterra_origin_pool" "juiceshop" {
    count = var.deploy_applications ? 1 : 0
    name      = format("%s-juiceshop-pool", var.name)
    namespace = var.application_namespace
    labels    = merge(local.tags,{})

    depends_on = [
        volterra_tf_params_action.action_test
    ]

    # Default: "DISTRIBUTED"
    # Enum: "DISTRIBUTED" "LOCAL_ONLY" "LOCAL_PREFERRED"
    # Policy for selection of endpoints from local site/remote site/both
    endpoint_selection = "LOCAL_PREFERRED"
    #Default: "ROUND_ROBIN"
    #Enum: "ROUND_ROBIN" "LEAST_REQUEST" "RING_HASH" "RANDOM" "LB_OVERRIDE"
    loadbalancer_algorithm = "LEAST_REQUEST"

    origin_servers {
        private_ip {
        ip             = azurerm_linux_virtual_machine.juiceshop[0].private_ip_address
        inside_network = true
        site_locator {
            site {
            namespace = "system"
            name      = volterra_azure_vnet_site.azure_site.name
            }
        }
        }

    }

    port = "3000"

    use_tls {
        no_mtls                  = true
        skip_server_verification = true
        use_host_header_as_sni   = true

        tls_config {
            default_security = true
        }
    }

}

resource "volterra_http_loadbalancer" "juiceshop" {
  name      = format("%s-juice-lb", var.name)
  namespace = var.application_namespace

  depends_on = [
    volterra_tf_params_action.action_test, volterra_origin_pool.juiceshop
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["juice.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  //Stop waisting certs for testing!
  http {
    dns_volterra_managed = true
  }

  # https_auto_cert {
  #   add_hsts      = true
  #   http_redirect = true
  #   no_mtls       = true

  # }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }
  user_identification {
    name      = format("%s-user-ident", var.name)
    namespace = var.application_namespace
    #tenant    = var.tenant
  }
  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  disable_waf = true
#   waf {
#     namespace = var.application_namespace
#     name      = "${var.application_namespace}-default-waf"
#   }

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-juiceshop-pool", var.name)
      namespace = var.application_namespace
    }
  }

}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "app" {
    count = var.deploy_applications ? 1 : 0
  name                = "${var.name}-app-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_3000"
    description                = "Allow 3000 access"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_9090"
    description                = "Allow 9090 access"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_5601"
    description                = "Allow 5601 access"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5601"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_9200"
    description                = "Allow 9200 access"
    priority                   = 170
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9200"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_9300"
    description                = "Allow 9300 access"
    priority                   = 180
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9300"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_9600"
    description                = "Allow 9600 access"
    priority                   = 190
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9600"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_5044"
    description                = "Allow 5044 access"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5044"
    source_address_prefixes    = local.trusted_cidrs
    destination_address_prefix = "*"
  }
  tags = merge(local.tags,{})
}