variable "prefix" {
  default = "santalucia"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "westeurope"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "main" {
  name                = "SantaluciaPIP"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  domain_name_label   = "santalucia-azurerm-resource"
}

resource "azurerm_network_interface" "main" {
  name                = "santalucia-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "main" {
    name                = "myNetworkSecurityGroupWinRm"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.main.name
    
    security_rule {
        name                       = "WinRm"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5985-5986"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
      security_rule {
        name                       = "Access-RDP"
        priority                   = 210
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  
     security_rule {
        name                       = "Access-http"
        priority                   = 220
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
       security_rule {
        name                       = "Access-ssh"
        priority                   = 230
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  
      security_rule {
        name                       = "InternetAccess"
        priority                   = 240
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

 data "azurerm_client_config" "current" {
}

#--------INSTALLING Machine from Image -------------------------
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_A2_v2"

 storage_os_disk {
    name            = "FromPackerImageOsDisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
}
storage_image_reference {
    id = "/subscriptions/2de9d718-d170-4e29-af3b-60c30e449b3c/resourceGroups/santalucia-imagenes-packer/providers/Microsoft.Compute/images/ws2016-winrm-packer"
}

  os_profile {
    computer_name  = "Prueba"
    admin_username = "arqsis"
    admin_password = "Password1234!"
  }
 
  os_profile_windows_config { 
     provision_vm_agent = true 
     winrm {
       protocol = "http"
           } 
                            } 
  }
#----------------------------------------------------------------------------
  
#--------INSTALLING ./ConfigureRemotingForAnsible.ps1 -------------------------
  resource "azurerm_virtual_machine_extension" "main" {
    name            = "hostname"
    virtual_machine_id  =  azurerm_virtual_machine.main.id
    publisher       = "Microsoft.Compute"
    type            = "CustomScriptExtension"
    type_handler_version    = "1.9"
 
    settings = <<SETTINGS
    {  
    "fileUris": ["C:\\ConfigureRemotingForAnsible.ps1"]  
    }
    SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -executionpolicy Unrestricted -file ./ConfigureRemotingForAnsible.ps1"
    }
    PROTECTED_SETTINGS
    }
#-----------------------------------------------------------------------------
