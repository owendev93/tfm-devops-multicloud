output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnets" {
  value = {
    for k, s in azurerm_subnet.subnets :
    k => s.id
  }
}
