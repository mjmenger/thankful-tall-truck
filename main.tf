terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.3"
    }
  }
}

resource "volterra_token" "new_site" {
  name      = format("%s-token", var.name)
  namespace = "system"
  labels    = local.tags
}
provider "azurerm" {
  features{}
}
variable deploy_azure_site {
  type    = bool
  default = false
}
variable deploy_azure_site_apps {
  type    = bool
  default = false
}
variable public_key_path {
  type = string
}
module azure_site {
    count                 = var.deploy_azure_site ? 1 : 0
    source                = "./azure-site"
    volterra_token        = volterra_token.new_site.id
    name                  = var.name
    azure_client_id       = var.azure_client_id
    azure_subscription_id = var.azure_subscription_id
    azure_tenant_id       = var.azure_tenant_id
    azure_client_secret   = var.azure_client_secret
    tags                  = local.tags
    location              = var.location
    public_key            = file(var.public_key_path)
    deploy_applications   = var.deploy_azure_site_apps
    application_namespace = "m-menger"
    delegated_domain      = "volterra.securecloud.engineering"
}

