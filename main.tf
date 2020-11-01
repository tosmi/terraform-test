provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.5.0"
  features {}
}

terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
  }
}

provider "ansible" {
  # Configuration options
}

# NOT mangaged by terraform
#
# resource "azurerm_resource_group" "tower" {
#     name     = "tower"
#     location = "eastus"

#     tags = {
#         environment = "Terraform Demo"
#     }
# }

# resource "azurerm_virtual_network" "tower-vnet" {
#     name                = "tower-vnet"
#     address_space       = ["10.0.0.0/24"]
#     location            = "eastus"
#     resource_group_name = azurerm_resource_group.tower.name

#     tags = {
#         environment = "Terraform Demo"
#     }
# }

# resource "azurerm_subnet" "default" {
#   name = "default"
#   resource_group_name =  azurerm_resource_group.tower.name
#   virtual_network_name = azurerm_virtual_network.tower-vnet.name
#   address_prefix = "10.0.0.0/24"
# }

resource "azurerm_network_interface" "devvm01-nic" {
  name = "devvm01-nic"
  location = "eastus"
  resource_group_name = "tower"

  ip_configuration {
    name = "ipconfig1"
    subnet_id = "/subscriptions/753e241c-7786-48a6-999a-99e0834b3b22/resourceGroups/tower/providers/Microsoft.Network/virtualNetworks/tower-vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
  }
}

# Create (and display) an SSH key
# resource "tls_private_key" "example_ssh" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }
# output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

resource "azurerm_linux_virtual_machine" "devvm01" {
    name                  = "devvm01"
    location              = "eastus"
    resource_group_name   = "tower"
    network_interface_ids = [azurerm_network_interface.devvm01-nic.id]
    size                  = "Standard_B1s"

    os_disk {
        name              = "devvm01-disk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "devvm01"
    admin_username = "rhadmin"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "rhadmin"
        public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5+XRG8zQozmbub+Yg4CyhdrKgsTF/tN/Mv/AZtnCXeT9zEvIuqD1pOKmwUeHmb/SEeF05AdUNKlkqXwn/RJdKsvLs99lWtsbpkIx+QU1zxOyOBGyT69VeQMFji6IuDfbBVRqnr+yq8ivPjgVHP5VbJd0ohFbCOBBls7Xz51RqXAfYjg38J/i9Dy1ClCh/lU5byG7jhusTzCkZE0Dk3DaLrh8zl7ft8yi9eHDaHPq/xpmm/0rDG97AAoVY7n8341aLRW9E8r2XpBakqRc2VV3Z3XLjBx0XgVGWGTUHj+V3aFTjI4cevK3R4UC/bcUEgfwfdk0sym53jowwjaakYunhyvRTxoQnznm8OHTHb/S2RxKBTRve6IsqrGol7a8ZS72umIr+Uta6AhJbeBXiWDQ6FW2BJEefG2QMy8tM3k0yqbP5UqUJtqU6mXo3pWNVdyRZ/4wuVx6Pl6fICfGcN+Mks6BLJTfEb+Hes+AZBPGaZGpz20tkU37Y3ty3M60CBGc= root@tower"
    }

    tags = {
      environment = "Terraform Demo"
      dev = "true"
    }
}
