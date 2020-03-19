# refer to a resource group
data "azurerm_resource_group" "test" {
  name = "myrg1"
}

#refer to a subnet
data "azurerm_subnet" "test" {
  name                 = "Subnet-1"
  virtual_network_name = "myvnet"
  resource_group_name  = "myrg1"
}

# Create public IPs
resource "azurerm_public_ip" "test" {
    name                         = "myPublicIP-test"
    location                     = "${data.azurerm_resource_group.test.location}"
    resource_group_name          = "${data.azurerm_resource_group.test.name}"
    public_ip_address_allocation = "dynamic"

}

# create a network interface
resource "azurerm_network_interface" "test" {
  name                = "nic-test"
  location            = "${data.azurerm_resource_group.test.location}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }
}
# Create virtual machine
resource "azurerm_virtual_machine" "test" {
    name                  = "myVM-test"
    location              = "${azurerm_network_interface.test.location}"
    resource_group_name   = "${data.azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.test.id}"]
    vm_size               = "Standard_DS1_v2"

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

# Uncomment this line to delete the data disks automatically when deleting the VM
delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
    os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
    os_profile_windows_config {
    provision_vm_agent = false
  }
}