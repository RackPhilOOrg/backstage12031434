module "lb" {
  source              = "Azure/loadbalancer/azurerm"
  version             = "4.4.0"
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location
  frontend_name       = "myPublicIp"
  type                = "public"
  lb_sku              = "Standard"
  pip_sku             = "Standard"
  lb_port = {
    http = ["80", "Tcp", "80"]
  }

  lb_probe = {
    http = ["Tcp", "80", ""]
  }
  depends_on = [azurerm_resource_group.compute]
}

resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  for_each = var.virtual_machines

  network_interface_id    = module.virtual_machines[each.key].network_interface_id
  ip_configuration_name   = "${each.key}-nic0"
  backend_address_pool_id = module.lb.azurerm_lb_backend_address_pool_id
}

resource "azurerm_lb_nat_rule" "ssh" {
  for_each = var.virtual_machines

  name                           = "${each.key}-SSH-NAT-Rule"
  resource_group_name            = var.computeResourceGroupName
  loadbalancer_id                = module.lb.azurerm_lb_id
  protocol                       = "Tcp"
  frontend_port                  = each.value.lb_frontend_nat_ssh_port
  backend_port                   = 22
  frontend_ip_configuration_name = "myPublicIp"
}

resource "azurerm_lb_nat_rule" "rdp" {
  for_each = var.virtual_machines

  name                           = "${each.key}-RDP-NAT-Rule"
  resource_group_name            = var.computeResourceGroupName
  loadbalancer_id                = module.lb.azurerm_lb_id
  protocol                       = "Tcp"
  frontend_port                  = each.value.lb_frontend_nat_rdp_port
  backend_port                   = 3389
  frontend_ip_configuration_name = "myPublicIp"
}

resource "azurerm_lb_nat_rule" "winrm" {
  for_each = var.virtual_machines

  name                           = "${each.key}-WINRM-NAT-Rule"
  resource_group_name            = var.computeResourceGroupName
  loadbalancer_id                = module.lb.azurerm_lb_id
  protocol                       = "Tcp"
  frontend_port                  = each.value.lb_frontend_nat_winrm_port
  backend_port                   = 5985
  frontend_ip_configuration_name = "myPublicIp"
}

resource "azurerm_network_interface_nat_rule_association" "ssh" {
  for_each = var.virtual_machines

  network_interface_id  = module.virtual_machines[each.key].network_interface_id
  ip_configuration_name = "${each.key}-nic0"
  nat_rule_id           = azurerm_lb_nat_rule.ssh[each.key].id
}

resource "azurerm_network_interface_nat_rule_association" "rdp" {
  for_each = var.virtual_machines

  network_interface_id  = module.virtual_machines[each.key].network_interface_id
  ip_configuration_name = "${each.key}-nic0"
  nat_rule_id           = azurerm_lb_nat_rule.rdp[each.key].id
}

resource "azurerm_network_interface_nat_rule_association" "winrm" {
  for_each = var.virtual_machines

  network_interface_id  = module.virtual_machines[each.key].network_interface_id
  ip_configuration_name = "${each.key}-nic0"
  nat_rule_id           = azurerm_lb_nat_rule.winrm[each.key].id
}

output "load_balancer_ip" {
  value = module.lb.azurerm_public_ip_address[0]
}

output "virtual_machine_ports" {
  value = [
    for vm_name, vm_config in var.virtual_machines : {
      name                       = vm_name
      lb_frontend_nat_rdp_port   = vm_config["lb_frontend_nat_rdp_port"]
      lb_frontend_nat_ssh_port   = vm_config["lb_frontend_nat_ssh_port"]
      lb_frontend_nat_winrm_port = vm_config["lb_frontend_nat_winrm_port"]

    }
  ]
}