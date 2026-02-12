### Minimal usage example
This module provisions an Azure API Management instance with diagnostics integrated with Application Insights and Log Analytics, and supports assigning APIM Service Contributor access to additional principals.

```hcl
module "dis_apim_multitenancy" {
  source = "./modules/dis_apim_multitenancy"

  # Required
  prefix          = "myapp"
  environment     = "dev"
  publisher_email = "platform@example.com"

  # Optional
  location      = "norwayeast"
  apim_rg_name  = ""
  publisher     = "Altinn"
  sku_name      = "Developer_1"

  # Diagnostics
  sampling_percentage = 0.0
  headers_to_log      = []
  body_bytes_to_log   = 0

  # Optional APIM role assignments (name => principal object id)
  apim_service_contributors = {
    "platform-team" = "00000000-0000-0000-0000-000000000000"
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_api_management.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | resource |
| [azurerm_api_management_diagnostic.apim_application_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_diagnostic) | resource |
| [azurerm_api_management_logger.apimlogger](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_logger) | resource |
| [azurerm_application_insights.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.apimlogs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.apimdiagnostics_settings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.apim_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.apim_service_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.apim_random_part](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apim_rg_name"></a> [apim\_rg\_name](#input\_apim\_rg\_name) | The name of the Resource Group in which the API Management service should be created. If not specified, a name will be generated. | `string` | `""` | no |
| <a name="input_apim_service_contributors"></a> [apim\_service\_contributors](#input\_apim\_service\_contributors) | A map of principal IDs to grant the 'API Management Service Contributor' role. The map key is a descriptive name for the assignment, and the value is the principal's object ID. | `map(string)` | `{}` | no |
| <a name="input_body_bytes_to_log"></a> [body\_bytes\_to\_log](#input\_body\_bytes\_to\_log) | The number of payload bytes (up to 8192) to log in Application Insights diagnostics. By default, no payload is logged. | `number` | `0` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment name (e.g., at22, dev, tt02, test, prod). | `string` | n/a | yes |
| <a name="input_headers_to_log"></a> [headers\_to\_log](#input\_headers\_to\_log) | A set of headers to log in Application Insights diagnostics. By default, no headers are logged. | `set(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be deployed. | `string` | `"norwayeast"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resources prefixes | `string` | n/a | yes |
| <a name="input_publisher"></a> [publisher](#input\_publisher) | The name of the publisher for the API Management service. | `string` | `"Altinn"` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | The email address of the publisher for the API Management service. | `string` | n/a | yes |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | Sampling percentage for Application Insights diagnostics. Set to 0.0 to log only errors. | `number` | `0.0` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name | `string` | `"Developer_1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apim_default_logger_id"></a> [apim\_default\_logger\_id](#output\_apim\_default\_logger\_id) | The resource ID of the default APIM logger connected to Application Insights. |
| <a name="output_apim_id"></a> [apim\_id](#output\_apim\_id) | The resource ID of the API Management service. |
| <a name="output_apim_rg_name"></a> [apim\_rg\_name](#output\_apim\_rg\_name) | The name of the resource group where APIM and diagnostics resources are deployed. |
| <a name="output_apim_service_name"></a> [apim\_service\_name](#output\_apim\_service\_name) | The name of the API Management service. |
