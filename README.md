# thankful-tall-truck

export VOLT_API_P12_FILE 
export VES_P12_PASSWORD 
export VOLT_API_URL 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | 0.11.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_volterra"></a> [volterra](#provider\_volterra) | 0.11.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_site"></a> [azure\_site](#module\_azure\_site) | ./azure-site | n/a |

## Resources

| Name | Type |
|------|------|
| [volterra_token.new_site](https://registry.terraform.io/providers/volterraedge/volterra/0.11.3/docs/resources/token) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | n/a | `any` | n/a | yes |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | n/a | `any` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | n/a | `any` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | n/a | `any` | n/a | yes |
| <a name="input_deploy_azure_site"></a> [deploy\_azure\_site](#input\_deploy\_azure\_site) | n/a | `bool` | `false` | no |
| <a name="input_deploy_azure_site_apps"></a> [deploy\_azure\_site\_apps](#input\_deploy\_azure\_site\_apps) | n/a | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->