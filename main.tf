terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.24.0"
    }
  }
}

provider   "azurerm"   { 
   #version   =   "= 2.0.0" 
   features   {} 
 } 

 resource   "azurerm_resource_group"   "Hitesh_rg"   { 
   name   =   "hitesh-rg" 
   location   =   "West Europe" 
 } 

 resource   "azurerm_virtual_network"   "Hitesh_vnet"   { 
   name   =   "test-vnet" 
   address_space   =   [ "10.0.0.0/16" ] 
   location   =   azurerm_resource_group.Hitesh_rg.location 
   resource_group_name   =   azurerm_resource_group.Hitesh_rg.name 
 } 

 resource   "azurerm_subnet"   "frontendsubnet"   { 
   name   =   "frontendSubnet" 
   resource_group_name   =    azurerm_resource_group.Hitesh_rg.name 
   virtual_network_name   =   azurerm_virtual_network.Hitesh_vnet.name 
   address_prefixes   =   ["10.0.1.0/24"]
 } 

 resource   "azurerm_public_ip"   "hitesh-publicip"   { 
   name   =   "pip1" 
   location   =   azurerm_resource_group.Hitesh_rg.location  
   resource_group_name   =   azurerm_resource_group.Hitesh_rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 } 

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            =  azurerm_resource_group.Hitesh_rg.location 
  resource_group_name = azurerm_resource_group.Hitesh_rg.name

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
}


 resource   "azurerm_network_interface"   "myvm1nic"   { 
   name   =   "myvm1-nic" 
   location   =   azurerm_resource_group.Hitesh_rg.location 
   resource_group_name   =   azurerm_resource_group.Hitesh_rg.name 

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   azurerm_subnet.frontendsubnet.id 
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.hitesh-publicip.id 
   } 
 } 

 resource   "azurerm_linux_virtual_machine"   "Hitesh"   { 
   name                    =   "Hitesh-vm"   
   location                =   azurerm_resource_group.Hitesh_rg.location 
   resource_group_name     =   azurerm_resource_group.Hitesh_rg.name 
   network_interface_ids   =   [ azurerm_network_interface.myvm1nic.id ] 
   size                    =   "Standard_B1s" 
   admin_username          =   "hitesh" 
   admin_password          =   "Password123!" 
   disable_password_authentication = false

   source_image_reference   { 
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" 
   } 

   os_disk   { 
     caching             =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   } 
 } 