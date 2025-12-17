locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-${var.environment}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_prefixes
  name                 = "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}
