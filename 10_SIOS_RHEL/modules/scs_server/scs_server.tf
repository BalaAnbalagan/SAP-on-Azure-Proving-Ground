data "azurerm_resource_group" "rg" {
  name = "${var.rg}"
}

data "azurerm_resource_group" "network_rg" {
  name = "${var.network_rg}"
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}"
  resource_group_name = "${data.azurerm_resource_group.network_rg.name}"
}

data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet}"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.network_rg.name}"
}


data "template_file" "cloudconfig" {
   count               = "${length(var.scs_ipmap)}"
   #template = "${file("./script.sh")}"
  template = "${file("${path.root}${var.scs_CloudinitscriptPath}")}"

     vars {
    hostname         = "${element(var.scs_server_hostnamelist, count.index)}"
    sid              = "${var.sid}"
  #  sapinst_gid      = "${var.sapinst_gid}"
  #  sapsys_gid       = "${var.sapsys_gid}"
  #  domain_name      = "${var.ad_domain_name}"
  #  ad_join_password = "${var.ad_join_pwd}"
  #  ledger_nfs_url   = "${var.ledger_nfs_url}"
  #  media_nfs_url    = "${var.media_nfs_url}"
  # sid_nfs_url      = "${var.sid_nfs_url}"
  #  is_prod          = "${var.prod}"
  }

}

#https://www.terraform.io/docs/providers/template/d/cloudinit_config.html
data "template_cloudinit_config" "config" {
count               = "${length(var.scs_ipmap)}"
  gzip          = true
  base64_encode = true


  part {
    content = "${element(data.template_file.cloudconfig.*.rendered, count.index)}"
  }

}
resource "azurerm_network_interface" "scs_server_nic" {
  count               = "${length(var.scs_ipmap)}"
  name                = "NIC_APP-${element(var.scs_server_hostnamelist, count.index)}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  #enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "PVT_IP-${element(var.scs_server_niclist, count.index)}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    primary                       = true
    private_ip_address            = "${lookup(var.scs_ipmap, element(var.scs_server_hostnamelist, count.index))}"
  }

  # tags = "${merge(var.tags_map, map("Name", element(var.scs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SCS"), map("Backup", var.backup))}"
}

resource "azurerm_availability_set" "av-set" {
  name                         = "AV-SET-SCS"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2

  #tags                = "${merge(var.tags_map, map("Name", element(var.db_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP Database"), map("Backup", var.backup))}"
}

resource "azurerm_virtual_machine" "scs_server" {
  count                            = "${length(var.scs_server_hostnamelist)}"
  name                             = "${element(var.scs_server_hostnamelist, count.index)}"
  location                         = "${data.azurerm_resource_group.rg.location}"
  resource_group_name              = "${data.azurerm_resource_group.rg.name}"
  primary_network_interface_id     = "${element(azurerm_network_interface.scs_server_nic.*.id,count.index)}"
  network_interface_ids            = ["${element(azurerm_network_interface.scs_server_nic.*.id,count.index)}"]
  vm_size                          = "${var.scs_vm_type}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  availability_set_id              = "${azurerm_availability_set.av-set.id}"

boot_diagnostics {
    enabled     = "true"
    storage_uri = "${var.DiagnosticDiskURI}"
  }

  storage_image_reference {
  publisher = "${var.scs_VMPublisherName}"
    offer   = "${var.scs_VMOffer}"
    sku     = "${var.scs_VMImageSku}"
    version = "latest"
  }

  storage_os_disk {
    name              = "OS_DISK-${element(var.scs_server_hostnamelist, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks

 storage_data_disk {
    name              = "usrsap-${element(var.scs_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "64"
  }
  storage_data_disk {
    name              = "usrsapsid-${element(var.scs_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = "64"
  }
  storage_data_disk {
    name              = "usrsapsidascs-${element(var.scs_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 2
    disk_size_gb      = "64"
  }
    storage_data_disk {
    name              = "usrsapsiders-${element(var.scs_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 3
    disk_size_gb      = "64"
  }
  os_profile {
    computer_name  = "${element(var.scs_server_hostnamelist, count.index)}"
    admin_username = "${var.VMAdminName}"
    admin_password = "${var.VMAdminPassword}"
    custom_data = "${element(data.template_cloudinit_config.config.*.rendered, count.index)}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${merge(var.tags_map, map("Name", element(var.scs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SCS"), map("Backup", var.backup))}"
}


/*
resource "azurerm_virtual_machine_extension" "scs_server_ext" {
  count                = "${length(var.scs_server_hostnamelist)}"
  name                 = "EXT-${element(var.scs_server_hostnamelist, count.index)}"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  virtual_machine_name = "${element(azurerm_virtual_machine.scs_server.*.name, count.index)}"
  publisher            = "Microsoft.Azure.Extensions"
  #type                 = "CustomScriptForLinux"
  type = "CustomScript"
  #type_handler_version = "1.2"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "fileUris": ["https://scriptstorageacct.blob.core.windows.net/script/diskformat.bash"]
    }
SETTINGS
protected_settings = <<PROTECTED_SETTINGS
{
"commandToExecute": "bash diskformat.bash",
"storageAccountName": "scriptstorageacct",
"storageAccountKey": "11pmnldKOxc4AvGEpREnxyMV9j+/GZ/lHlQcXRs0LpR24+T4tn3oFp+DujUdGzR9ORWtIzwwlvuEnDjGZl5plA=="
}
PROTECTED_SETTINGS

  tags = "${merge(var.tags_map, map("Name", element(var.scs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SCS"), map("Backup", var.backup))}"
}

*/