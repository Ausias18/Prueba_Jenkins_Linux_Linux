variable "prefix" {
  default = "santalucia"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources-for-Linux"
  location = "westeurope"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.2.0/24"
}

#resource "azurerm_public_ip" "main" {
#  name                = "SantaluciaPIP"
#  location            = "westeurope"
#  resource_group_name = azurerm_resource_group.main.name
#  allocation_method   = "Static"
#  domain_name_label   = "santalucia-azurerm-resource"
#}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "main" {
    name                = "myNetworkSecurityGroupWinRm"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.main.name
    
    security_rule {
        name                       = "Access-SSH"
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
        name                       = "Access-http"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  
      security_rule {
        name                       = "InternetAccess"
        priority                   = 1010
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

#resource "azurerm_network_interface_security_group_association" "main" {
#  network_interface_id      = azurerm_network_interface.main.id
#  network_security_group_id = azurerm_network_security_group.main.id
#}

# data "azurerm_client_config" "current" {
#}

#--------INSTALLING Machine from Image -------------------------
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm-linux"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_A2_v2"

 storage_image_reference {
    id = "/subscriptions/2de9d718-d170-4e29-af3b-60c30e449b3c/resourceGroups/santalucia-imagenes-packer/providers/Microsoft.Compute/images/linux-image-packer"
}
  
 storage_os_disk {
    name            = "FromPackerImageOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}
 
  os_profile{
    computer_name  = "Prueba-Linux"
    admin_username = "arqsis"
    admin_password = "Password1234!"
    }
    
   os_profile_linux_config {
    disable_password_authentication = false
     }

    }
 #----------------------------------------------------------------------------
