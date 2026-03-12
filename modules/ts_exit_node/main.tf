locals {
  tags = merge(var.tags, { submodule = "ts-exit-node" })
}

resource "azurerm_virtual_network" "main" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = [var.ipv4_cidr_vnet, var.ipv6_cidr_vnet]
  tags                = local.tags
}

resource "azurerm_subnet" "main" {
  name                 = var.name
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ipv4_cidr_subnet, var.ipv6_cidr_subnet]
  service_endpoints    = var.service_endpoints
}

resource "azurerm_public_ip" "ipv4" {
  name                = "${var.name}4"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  ip_version          = "IPv4"
  allocation_method   = "Static"
  tags                = local.tags
}

resource "azurerm_public_ip" "ipv6" {
  name                = "${var.name}6"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  ip_version          = "IPv6"
  allocation_method   = "Static"
  tags                = local.tags
}

resource "azurerm_network_security_group" "main" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  tags                = local.tags

  security_rule {
    name                       = "AllowTailscale"
    priority                   = 100
    protocol                   = "Udp"
    direction                  = "Inbound"
    access                     = "Allow"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "41641"
  }
}

resource "azurerm_network_interface" "main" {
  name                  = var.name
  resource_group_name   = var.resource_group
  location              = var.location
  ip_forwarding_enabled = true
  tags                  = local.tags

  ip_configuration {
    name                          = var.name
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.ipv4.id
    primary                       = true
  }

  ip_configuration {
    name                          = "${var.name}6"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv6"
    public_ip_address_id          = azurerm_public_ip.ipv6.id
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "tls_private_key" "admin" {
  algorithm = "ED25519"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  size                = "Standard_B2als_v2"
  admin_username      = "azureuser"
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.main.id]
  custom_data           = base64encode(templatefile("${path.module}/cloud-init.tpl", { tailscale_auth_key = var.tailscale_auth_key }))

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }

  plan {
    name      = "9-base"
    product   = "rockylinux-x86_64"
    publisher = "resf"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin.public_key_openssh
  }

  vtpm_enabled        = true
  secure_boot_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

