terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}


locals {
  resource_group="sameerkhule001"
  location="West Europe"
  dns1="cgi-challenge1"
}

data "azurerm_subnet" "default" {
  name                 = "default"
  virtual_network_name = "sameerkhule001-vnet"
  resource_group_name  = local.resource_group
}

# public ip
resource "azurerm_public_ip" "tf2-public-ip" {
  name                = "tf2-public-ip"
  resource_group_name = local.resource_group
  location            = local.location
  allocation_method   = "Static"
  domain_name_label   = local.dns1
}
#output the fqdn
output "test_static_fqdn" {
  value = "${azurerm_public_ip.tf2-public-ip.fqdn}"
}

# network security group and rule
resource "azurerm_network_security_group" "tf2-vm-nsg" {
  name                = "tf2-vm-nsg"
  location            = local.location
  resource_group_name = local.resource_group

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 990
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# network interface
resource "azurerm_network_interface" "tf2-network_interface" {
  name                = "tf2-network_interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.tf2-public-ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "tf2-association" {
  network_interface_id      = azurerm_network_interface.tf2-network_interface.id
  network_security_group_id = azurerm_network_security_group.tf2-vm-nsg.id
}

# vm
resource "azurerm_linux_virtual_machine" "tf2-vm" {
  name                = "tf2-vm"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  admin_password      = "123456789"
  network_interface_ids = [
    azurerm_network_interface.tf2-network_interface.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/sameer/terraform/id_rsa.pub")
    #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJsDjuUKqCHcaE9qFijqem4ZcPPXT0S81q0ox7jug//kZWt5mtNUmJD3T2kVocS1FvTNivHJB0UcyVPXN4ed5rOHHmRkewnTsNkDbYo20DzTkw4Cug8PoIkYOYxJ6nvVKyJmNol14jq4SS4DWKx83Tkx4gYtoSMuhvpLbRjrGz/U50xtKla6d88Ue5b7xf9I2ign6SSIhAxkKXRuBwHD9TwwDifR7PMaAINn5LPxYV5SDxSfmrh0rKk7vwxiDs6l+/Ce1TUB7ijmEINZkqs8u3KU7wX1tpQGz568U+hkHNGc0YLRwwozGsIdFzThOEpi1x/caRQ3b2npDVuK2n51JaV4Lhq7Sq/ebRPm+PgBre2n6Pj9c3P3V257z4Tl86RsfbyH3HpIWCS/IjtzX8FMvoY2J2STdQrvmDepxNhrc6sITo/Tg+DeplfOvB2TGdnr0NBgD59W7XKHR8t6IhexwE7Gh9dbZJtMnCoR7ta92+EIGa8D77iH1bfIYCxeHOIKk= root@ansible-master"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
