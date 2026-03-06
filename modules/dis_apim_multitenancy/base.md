# dis_apim_multitenancy

Deploys a multi-tenant Azure API Management service with Log Analytics, Application Insights, diagnostics, and RBAC.

## Usage

```hcl
module "dis_apim_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_apim_multitenancy?ref=<version>"

  prefix      = var.prefix
  environment = var.environment

  publisher_email = var.apim_publisher_email
}
```
