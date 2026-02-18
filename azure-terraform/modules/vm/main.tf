resource "azurerm_network_interface" "this" {
  name = "${var.vm_name}-nic"
  location = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name = "interval"
    subnet_id = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name = var.vm_name
  resource_group_name = var.resource_group_name
  location = var.location
  size = var.vm_size
  admin_username = "azureuser"
  network_interface_ids = [azurerm_network_interface.this.id]

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = var.tags
}

