locals {
    tags = merge(var.tags,{})
    auto_trusted_cidr = var.auto_trust_localip ? ["${jsondecode(data.http.myip[0].body).ip}/32"] : []
    # trusted CIDRs are a combination of CIDRs manually set through a tfvar
    # the CIDR of the VPC, and an automatically discovered CIDR if enabled
    # by auto_trust_localip
    trusted_cidr = concat(var.trusted_cidr,local.auto_trusted_cidr)
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


variable trusted_cidr {
    type = list(string)
    default = []
}
variable auto_trust_localip {
  type        = bool
  default     = false
  description = "if true, query ifconfig.io for public ip of terraform host."
}
data http myip {
  count = var.auto_trust_localip ? 1 : 0
  url   = "https://ifconfig.io/all.json"
}