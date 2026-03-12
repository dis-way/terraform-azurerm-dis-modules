## Usage

```hcl
module "ts_exit_node" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/ts_exit_node"

  name           = "ts-exit-prod"
  resource_group = "rg-networking"
  location       = "swedencentral"

  ipv4_cidr_vnet   = "172.30.1.0/24"
  ipv4_cidr_subnet = "172.30.1.0/27"
  ipv6_cidr_vnet   = "fd00:dead:beef::/48"
  ipv6_cidr_subnet = "fd00:dead:beef:1::/64"

  tailscale_auth_key = var.tailscale_auth_key
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.ipv4](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.ipv6](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [tls_private_key.admin](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ipv4_cidr_subnet"></a> [ipv4\_cidr\_subnet](#input\_ipv4\_cidr\_subnet) | IPv4 CIDR block for the subnet (e.g. 172.30.1.0/27) | `string` | n/a | yes |
| <a name="input_ipv4_cidr_vnet"></a> [ipv4\_cidr\_vnet](#input\_ipv4\_cidr\_vnet) | IPv4 CIDR block for the virtual network (e.g. 172.30.1.0/24) | `string` | n/a | yes |
| <a name="input_ipv6_cidr_subnet"></a> [ipv6\_cidr\_subnet](#input\_ipv6\_cidr\_subnet) | IPv6 /64 CIDR block for the subnet | `string` | n/a | yes |
| <a name="input_ipv6_cidr_vnet"></a> [ipv6\_cidr\_vnet](#input\_ipv6\_cidr\_vnet) | IPv6 ULA /48 CIDR block for the virtual network | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name used for all resources in this node (e.g. ts-exit-test) | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the resource group to deploy into | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | List of service endpoints to enable on the subnet (e.g. Microsoft.Sql, Microsoft.Storage) | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources, merged with submodule tag | `map(string)` | `{}` | no |
| <a name="input_tailscale_auth_key"></a> [tailscale\_auth\_key](#input\_tailscale\_auth\_key) | n/a | `string` | n/a | yes |
