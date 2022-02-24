locals {
    tags = merge(var.tags,{})
}

variable name {
    type = string
}
variable application_namespace{
    type    = string
    default = ""
}
variable "delegated_domain" {
    type    = string
    default = ""
}
variable tags {
    type = map(string)
}

variable azure_subscription_id{}
variable azure_client_id{}
variable azure_client_secret{}
variable azure_tenant_id{}
variable location {
    type = string
}