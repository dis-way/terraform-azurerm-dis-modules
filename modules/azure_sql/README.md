### Minimal usage example
This module provisions an Azure SQL database with a private endpoint and Entra ID-only authentication via a user-assigned managed identity. It supports both serverless (GP_S_Gen5, zone-redundant) and standard DTU (S-tier) modes.

```hcl
module "azure_sql" {
  source = "./modules/azure_sql"

  # Required identifiers
  prefix      = "myapp"
  environment = "dev"

  # Database
  database_name = "myappdb"

  # Entra ID admin group — the UAMI created by this module is added to this group. Terraform runner needs permissions to add memebers to the group
  database_admin_group_object_id = "00000000-0000-0000-0000-000000000001"
  database_admin_group_name      = "myapp-dev-sql-admins"

  # Network — subnet must be IPv4-only and dedicated to private endpoints
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myapp-dev-network-rg/providers/Microsoft.Network/virtualNetworks/myapp-dev-vnet/subnets/pe-subnet"

  tags = {
    environment = "dev"
    component   = "azure-sql"
  }
}
```

### Serverless example (with optional parameters)
```hcl
module "azure_sql" {
  source = "./modules/azure_sql"

  # Required identifiers
  prefix      = "myapp"
  environment = "prod"

  # Region
  location = "norwayeast"

  # Database
  database_name = "myappdb"

  # Entra ID admin group — the UAMI created by this module is added to this group. Terraform runner needs permissions to add memebers to the group
  database_admin_group_object_id = "00000000-0000-0000-0000-000000000001"
  database_admin_group_name      = "myapp-prod-sql-admins"

  # Serverless mode (default) — zone-redundant, GP_S_Gen5 SKU
  serverless = true
  min_cores  = 0.5
  max_cores  = 4

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

### DTU (Standard tier) example
```hcl
module "azure_sql" {
  source = "./modules/azure_sql"

  # Required identifiers
  prefix      = "myapp"
  environment = "prod"

  # Database
  database_name = "myappdb"

  # Entra ID admin group — the UAMI created by this module is added to this group. Terraform runner needs permissions to add memebers to the group
  database_admin_group_object_id = "00000000-0000-0000-0000-000000000001"
  database_admin_group_name      = "myapp-prod-sql-admins"

  # Standard DTU mode — uses Local storage, zone redundancy not available
  serverless = false
  dtu_sku    = "S3"

  # Network — subnet must be IPv4-only and dedicated to private endpoints
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myapp-prod-network-rg/providers/Microsoft.Network/virtualNetworks/myapp-prod-vnet/subnets/pe-subnet"

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
| `uami_client_id` | Client ID of the UAMI |
| `server_id` | Resource ID of the SQL server |
| `server_fqdn` | Fully qualified domain name of the SQL server |
| `database_id` | Resource ID of the SQL database |
| `database_name` | Name of the SQL database |
| `private_endpoint_id` | Resource ID of the private endpoint |
| `private_endpoint_ip` | Private IP address allocated to the SQL server private endpoint |
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.53.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.53.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5 |

## Resources

| Name | Type |
| ---- | ---- |
| [azuread_group_member.azsql_uami_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_mssql_database.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_server.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_private_endpoint.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.azsql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.db_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_autopause_after_mins"></a> [autopause\_after\_mins](#input\_autopause\_after\_mins) | Number of minutes of inactivity before auto-pause. Azure enforces a minimum of 60. Only used when serverless = true and enable\_autopause = true. | `number` | `60` | no |
| <a name="input_database_admin_group_name"></a> [database\_admin\_group\_name](#input\_database\_admin\_group\_name) | Database admin group name. | `string` | n/a | yes |
| <a name="input_database_admin_group_object_id"></a> [database\_admin\_group\_object\_id](#input\_database\_admin\_group\_object\_id) | Database admin group object id. This group will be granted admin rights and the User Assigned Managed Identity created in this module will be added to the group. Terraform user needs permissions to add users to group | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database that will be deployed on this server | `string` | n/a | yes |
| <a name="input_dtu_sku"></a> [dtu\_sku](#input\_dtu\_sku) | Standard DTU performance level to use when serverless = false. Valid values: S0, S1, S2, S3, S4, S6, S7, S9, S12. | `string` | `"S2"` | no |
| <a name="input_enable_autopause"></a> [enable\_autopause](#input\_enable\_autopause) | Whether to enable auto-pause for the serverless database. Only used when serverless = true. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for resources (required, max 4 characters). Combined with prefix, must not exceed 12 characters for storage account naming. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Default region for resources | `string` | `"norwayeast"` | no |
| <a name="input_max_cores"></a> [max\_cores](#input\_max\_cores) | Maximum vCores for serverless scaling. Only used when serverless = true. | `number` | `2` | no |
| <a name="input_min_cores"></a> [min\_cores](#input\_min\_cores) | Minimum vCores for serverless scaling. Must be at least 0.5 and no greater than max\_cores. Only used when serverless = true. | `number` | `0.5` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names (required, max 8 characters). Combined with environment, must not exceed 12 characters for storage account naming. | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The resource ID of the private DNS zone (privatelink.database.windows.net) to associate with the SQL private endpoint. Leave empty to skip DNS zone group creation. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | The ID of the subnet in which to deploy the private endpoint for the SQL server. | `string` | n/a | yes |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created. | `string` | `"12.0"` | no |
| <a name="input_serverless"></a> [serverless](#input\_serverless) | Whether to deploy the database in serverless mode (GP\_S\_Gen5) or standard DTU mode (S-tier). When false, dtu\_sku is used and serverless-specific settings (max\_cores, min\_cores, enable\_autopause, autopause\_after\_mins) are ignored. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | The resource ID of the SQL database |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The name of the SQL database |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The resource ID of the SQL server private endpoint |
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | The private IP address allocated to the SQL server private endpoint |
| <a name="output_server_fqdn"></a> [server\_fqdn](#output\_server\_fqdn) | The fully qualified domain name of the SQL server |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | The resource ID of the SQL server |
| <a name="output_uami_client_id"></a> [uami\_client\_id](#output\_uami\_client\_id) | The client\_ID of the User Assigned Managed Identity |
| <a name="output_uami_id"></a> [uami\_id](#output\_uami\_id) | The resource ID of the User Assigned Managed Identity used for SQL server authentication |
| <a name="output_uami_principal_id"></a> [uami\_principal\_id](#output\_uami\_principal\_id) | The principal (object) ID of the User Assigned Managed Identity |
