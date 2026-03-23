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
