resource "azurerm_data_factory" "df" {
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  name = "df-${var.solution_name}-${var.environment}-${var.instance_number}"
  identity {
    type = "SystemAssigned"
  }
  managed_virtual_network_enabled = true
  depends_on = [ 
    azurerm_resource_group.rg,
    data.azurerm_subnet.snet_transit
  ]
}

resource "azurerm_private_endpoint" "df_pe_datafactory" {
  name                = "pe-${azurerm_data_factory.df.name}-datafactory"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${azurerm_data_factory.df.name}-datafactory"
    private_connection_resource_id = azurerm_data_factory.df.id
    is_manual_connection           = false
    subresource_names              = ["dataFactory"]
  }

  depends_on = [ azurerm_data_factory.df ]
}

resource "azurerm_private_endpoint" "df_pe_portal" {
  name                = "pe-${azurerm_data_factory.df.name}-portal"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${azurerm_data_factory.df.name}-portal"
    private_connection_resource_id = azurerm_data_factory.df.id
    is_manual_connection           = false
    subresource_names              = ["portal"]
  }

  depends_on = [ azurerm_data_factory.df ]
}
