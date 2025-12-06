# resource "azurerm_virtual_network" "vnet" {
#   name = "vnet-${var.solution_name}-${var.environment}-01"
#   address_space = [ 
#     var.vnet_ip_cidr
#   ]
#   resource_group_name = azurerm_resource_group.rg.name
#   location = azurerm_resource_group.rg.location
# }

# resource "azurerm_virtual_network" "vnet-unpeered" {
#   name = "vnet-${var.solution_name}-${var.environment}-backend-01"
#   address_space = [
#     "10.0.0.0/16"
#   ]
#   resource_group_name = azurerm_resource_group.rg.name
#   location = azurerm_resource_group.rg.location
# }

# # Azure resources subnet
# resource "azurerm_subnet" "snet" {
#   for_each = { for k, v in var.snet_ip_cidr : k => v }
#   address_prefixes = [ var.snet_ip_cidr[each.key] ]
#   name = "snet-${var.solution_name}-${var.environment}-${format("%02d",each.key)}"
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   service_endpoints = [
#     "Microsoft.Storage",
#     "Microsoft.KeyVault",
#   ]
#   depends_on = [ 
#     azurerm_virtual_network.vnet 
#   ]
# }

# # Databricks VNet Injection
# resource "azurerm_subnet" "dbw_public" {
#   address_prefixes = [ "10.0.64.0/18" ]
#   name = "snet-dbw-${var.solution_name}-${var.environment}-public"
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet-unpeered.name
#   service_endpoints = ["Microsoft.Storage"]
#   delegation {
#     name = "databricks-del-public"
#     service_delegation {
#       name = "Microsoft.Databricks/workspaces"
#       actions = [
#         "Microsoft.Network/virtualNetworks/subnets/join/action",
#         "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
#         "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
#       ]
#     }
#   }
#   depends_on = [
#     azurerm_virtual_network.vnet-unpeered
#   ]
# }

# resource "azurerm_subnet" "dbw_private" {
#   address_prefixes = [ "10.0.0.0/18" ]
#   name = "snet-dbw-${var.solution_name}-${var.environment}-private"
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet-unpeered.name
#   service_endpoints = ["Microsoft.Storage"]
#   delegation {
#     name = "databricks-del-private"
#     service_delegation {
#       name = "Microsoft.Databricks/workspaces"
#       actions = [
#         "Microsoft.Network/virtualNetworks/subnets/join/action",
#         "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
#         "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
#       ]
#     }
#   }
  
#   depends_on = [
#     azurerm_virtual_network.vnet-unpeered
#   ]
# }
