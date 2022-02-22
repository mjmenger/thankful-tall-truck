<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | 0.11.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_volterra"></a> [volterra](#provider\_volterra) | 0.11.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [volterra_azure_vnet_site.azure_site](https://registry.terraform.io/providers/volterraedge/volterra/0.11.3/docs/resources/azure_vnet_site) | resource |
| [volterra_cloud_credentials.azure_site](https://registry.terraform.io/providers/volterraedge/volterra/0.11.3/docs/resources/cloud_credentials) | resource |
| [volterra_tf_params_action.action_test](https://registry.terraform.io/providers/volterraedge/volterra/0.11.3/docs/resources/tf_params_action) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | n/a | `any` | n/a | yes |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | n/a | `any` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | n/a | `any` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | n/a | `any` | n/a | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `string` | `"10.0.0.0/16"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | a common name prefix | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | n/a | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_volterra_token"></a> [volterra\_token](#input\_volterra\_token) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->