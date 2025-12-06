data "azurerm_virtual_network" "vnet" {
  name                = local.vnet
  resource_group_name = "rg-org-c"
}

data "azurerm_subnet" "snet_transit" {
  name                 = var.snet_transit
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_subnet" "snet_adb_private" {
  name                 = var.snet_adb_private
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_subnet" "snet_adb_public" {
  name                 = var.snet_adb_public
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_subnet" "snet_k8s" {
  name                 = var.snet_k8s
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azuread_groups" "do_admins" {
  display_names = ["Subscription-Admin-Group"]
}

data "azurerm_log_analytics_workspace" "law" {
  resource_group_name = local.log_analytics_workspace_resource_group_name
  name = local.log_analytics_workspace_name
}

data "azurerm_key_vault" "orgroot_kv" {
  name                = "akv-org-all-01"
  resource_group_name = "rg-org-all"
}
