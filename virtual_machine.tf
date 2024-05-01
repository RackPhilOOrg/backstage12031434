resource "azurerm_storage_account" "example" {
  name                     = "bootstrpsto"
  resource_group_name      = azurerm_resource_group.compute.name
  location                 = azurerm_resource_group.compute.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "bootstrap"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob" # public read access for blobs only
}

# Grant access to the read only service principal so future plans can complete (need to access the storage key)
resource "azurerm_role_assignment" "builtin_role_assignment" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Reader and Data Access"
  principal_id         = "SP_RO_ENT_OBJ_ID"
}

module "virtual_machines" {
  source  = "Azure/virtual-machine/azurerm"
  version = "1.1.0"

  for_each = var.virtual_machines

  resource_group_name = var.computeResourceGroupName
  location            = azurerm_resource_group.compute.location
  image_os            = "windows"
  os_simple           = "WindowsServer"
  name                = each.key
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  subnet_id                  = module.network.vnet_subnets[0]
  size                       = "Standard_F2"
  admin_password             = "VM_PASSWORD"
  admin_username             = "VM_USERNAME"
  allow_extension_operations = true
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  for_each = var.virtual_machines

  virtual_machine_id = module.virtual_machines[each.key].vm_id
  location           = azurerm_resource_group.compute.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "GMT Standard Time"

  notification_settings {
    enabled = false
  }
}

# Upload the script file to the Blob
resource "azurerm_storage_blob" "script_blob" {
  name                   = "config_script.ps1"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "${path.module}/config_script.ps1"
}

# Define the virtual machine extension to execute the script
resource "azurerm_virtual_machine_extension" "custom_script" {
  for_each = var.virtual_machines

  name                 = "config_script"
  virtual_machine_id   = module.virtual_machines[each.key].vm_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    "commandToExecute" = "powershell.exe -Command \"Invoke-WebRequest -Uri '${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}/config_script.ps1' -OutFile 'config_script.ps1'; .\\config_script.ps1\""
  })

  depends_on = [module.virtual_machines, azurerm_storage_blob.script_blob]
}

resource "azurerm_virtual_machine_extension" "ssh_extension" {
  for_each = var.virtual_machines

  name                 = "OpenSSH_${each.key}"
  virtual_machine_id   = module.virtual_machines[each.key].vm_id
  publisher            = "Microsoft.Azure.OpenSSH"
  type                 = "WindowsOpenSSH"
  type_handler_version = "3.0"
}
