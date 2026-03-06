## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.3.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.syncroot](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_id"></a> [aks\_cluster\_id](#input\_aks\_cluster\_id) | The ID of the AKS cluster where the Flux configuration will be applied | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Name of the product | `string` | n/a | yes |
| <a name="input_prune_enabled"></a> [prune\_enabled](#input\_prune\_enabled) | Control if the syncroot enables prune of resources | `bool` | `false` | no |
