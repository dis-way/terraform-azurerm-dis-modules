### Minimal usage example
This module provisions an Azure SQL serverless database with a private endpoint, Entra ID-only authentication via a user-assigned managed identity, and zone-redundant storage.

```hcl
module "azure_sql" {
  source = "./modules/azure_sql"

  # Required identifiers
  prefix      = "myapp"
  environment = "dev"

  # Network — subnet must be IPv4-only and dedicated to private endpoints
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myapp-dev-network-rg/providers/Microsoft.Network/virtualNetworks/myapp-dev-vnet/subnets/pe-subnet"

  tags = {
    environment = "dev"
    component   = "azure-sql"
  }
}
```

### Full usage example (with optional parameters)
```hcl
module "azure_sql" {
  source = "./modules/azure_sql"

  # Required identifiers
  prefix      = "myapp"
  environment = "prod"

  # Region
  location = "norwayeast"

  # Serverless compute scaling
  min_cores = 0.5
  max_cores = 4

  # Auto-pause (disable in production if cold-start latency is unacceptable)
  enable_autopause     = false
  autopause_after_mins = 60

  # Server version
  server_version = "12.0"

  # Network — subnet must be IPv4-only and dedicated to private endpoints
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myapp-prod-network-rg/providers/Microsoft.Network/virtualNetworks/myapp-prod-vnet/subnets/pe-subnet"

  # DNS — omit to skip automatic DNS registration
  private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myapp-prod-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"

  tags = {
    environment = "prod"
    component   = "azure-sql"
    managed-by  = "terraform"
  }
}
```

### Outputs

| Name | Description |
|------|-------------|
| `uami_id` | Resource ID of the User Assigned Managed Identity used for SQL authentication |
| `uami_principal_id` | Principal (object) ID of the UAMI — use this to grant Azure RBAC roles |
| `server_id` | Resource ID of the SQL server |
| `server_fqdn` | Fully qualified domain name of the SQL server |
| `database_id` | Resource ID of the SQL database |
| `database_name` | Name of the SQL database |
| `private_endpoint_id` | Resource ID of the private endpoint |
| `private_endpoint_ip` | Private IP address allocated to the SQL server private endpoint |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.53.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.53.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_database.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_server.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_private_endpoint.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.db_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autopause_after_mins"></a> [autopause\_after\_mins](#input\_autopause\_after\_mins) | Number of minutes before auto pause, if enable\_autopause is true. Azure enforces a minimum of 60. | `number` | `60` | no |
| <a name="input_enable_autopause"></a> [enable\_autopause](#input\_enable\_autopause) | n/a | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for resources (required, max 4 characters). Combined with prefix, must not exceed 12 characters for storage account naming. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Default region for resources | `string` | `"norwayeast"` | no |
| <a name="input_max_cores"></a> [max\_cores](#input\_max\_cores) | n/a | `number` | `2` | no |
| <a name="input_min_cores"></a> [min\_cores](#input\_min\_cores) | n/a | `number` | `0.5` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names (required, max 8 characters). Combined with environment, must not exceed 12 characters for storage account naming. | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The resource ID of the private DNS zone (privatelink.database.windows.net) to associate with the SQL private endpoint. Leave empty to skip DNS zone group creation. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | The ID of the subnet in which to deploy the private endpoint for the SQL server. | `string` | n/a | yes |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created. | `string` | `"12.0"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | The resource ID of the SQL database |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The name of the SQL database |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The resource ID of the SQL server private endpoint |
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | The private IP address allocated to the SQL server private endpoint |
| <a name="output_server_fqdn"></a> [server\_fqdn](#output\_server\_fqdn) | The fully qualified domain name of the SQL server |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | The resource ID of the SQL server |
| <a name="output_uami_client_id"></a> [uami\_client\_id](#output\_uami\_client\_id) | The client\_ID of the User Assigned Managed Identity |
| <a name="output_uami_id"></a> [uami\_id](#output\_uami\_id) | The resource ID of the User Assigned Managed Identity used for SQL server authentication |
| <a name="output_uami_principal_id"></a> [uami\_principal\_id](#output\_uami\_principal\_id) | The principal (object) ID of the User Assigned Managed Identity |
