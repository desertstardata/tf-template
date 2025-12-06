# Network security groups required for databricks workspace vnet injection
resource "azurerm_network_security_group" "nsg" {
  name = "nsg-${var.solution_name}-${var.environment}-${var.instance_number}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_dbw" {
  subnet_id = data.azurerm_subnet.snet_adb_public.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_private" {
  subnet_id = data.azurerm_subnet.snet_adb_private.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_rule" "nsr-worker-to-worker-inbound" {
   access = "Allow"
   description = "Required for worker nodes communication within a cluster."
   destination_address_prefix = "VirtualNetwork"
   destination_port_range = "*"
   direction = "Inbound"
   name = "dbw-worker-to-worker-inbound"
   network_security_group_name = azurerm_network_security_group.nsg.name
   priority = 101
   protocol = "*"
   resource_group_name = azurerm_resource_group.rg.name
   source_address_prefix = "VirtualNetwork"
   source_port_range = "*"
   depends_on = [
      azurerm_network_security_group.nsg
   ]
}

resource "azurerm_network_security_rule" "nsr-worker-to-databricks-cp" {
   access = "Allow"
   description = "Required for workers communication with Databricks control plane."
   destination_address_prefix = "AzureDatabricks"
   destination_port_ranges = [
    "443",
    "8443-8451",
    "3306"
   ]
   direction = "Outbound"
   name = "dbw-worker-to-cp-outbound"
   network_security_group_name = azurerm_network_security_group.nsg.name
   priority = 105
   protocol = "Tcp"
   resource_group_name = azurerm_resource_group.rg.name
   source_address_prefix = "VirtualNetwork"
   source_port_range = "*"
   depends_on = [
      azurerm_network_security_group.nsg
   ]
}

resource "azurerm_network_security_rule" "nsr-worker-to-sql" {
   access = "Allow"
   description = "Required for workers communication with Azure SQL services."
   destination_address_prefix = "Sql"
   destination_port_range = "3306"
   direction = "Outbound"
   name = "dbw-worker-to-sql-outbound"
   network_security_group_name = azurerm_network_security_group.nsg.name
   priority = 106
   protocol = "Tcp"
   resource_group_name = azurerm_resource_group.rg.name
   source_address_prefix = "VirtualNetwork"
   source_port_range = "*"
   depends_on = [
      azurerm_network_security_group.nsg
   ]
}

resource "azurerm_network_security_rule" "nsr-worker-to-storage" {
   access = "Allow"
   description = "Required for workers communication with Azure Storage services."
   destination_address_prefix = "Storage"
   destination_port_range = "443"
   direction = "Outbound"
   name = "dbw-worker-to-storage-outbound"
   network_security_group_name = azurerm_network_security_group.nsg.name
   priority = 107
   protocol = "Tcp"
   resource_group_name = azurerm_resource_group.rg.name
   source_address_prefix = "VirtualNetwork"
   source_port_range = "*"
   depends_on = [
      azurerm_network_security_group.nsg
   ]
}

resource "azurerm_network_security_rule" "nsr-worker-to-worker-outbound" {
   access = "Allow"
   description = "Required for worker nodes communication within a cluster."
   destination_address_prefix = "VirtualNetwork"
   destination_port_range = "*"
   direction = "Outbound"
   name = "dbw-worker-to-worker-outbound"
   network_security_group_name = azurerm_network_security_group.nsg.name
   priority = 108
   protocol = "*"
   resource_group_name = azurerm_resource_group.rg.name
   source_address_prefix = "VirtualNetwork"
   source_port_range = "*"
   depends_on = [
      azurerm_network_security_group.nsg
   ]
}

resource "azurerm_network_security_rule" "nsr-worker-to-eventhub" {
   access = "Allow"
   description = "Required for worker communication with Azure Eventhub services."
   destination_address_prefix = "EventHub"
   destination_port_range = "9093"
   direction = "Outbound"
   name = "dbw-worker-to-eventhub-outbound"
   network_security_group_name = azurerm_network_security_group.nsg.name
   priority = 109
   protocol = "Tcp"
   resource_group_name = azurerm_resource_group.rg.name
   source_address_prefix = "VirtualNetwork"
   source_port_range = "*"
   depends_on = [
      azurerm_network_security_group.nsg
   ]
}