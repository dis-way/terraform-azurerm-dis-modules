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

  tailscale_auth_key              = var.tailscale_auth_key
  ansible_pull_gh_app_private_key = var.ansible_pull_gh_app_private_key
}
```
