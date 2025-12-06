resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"  # premium required for private vnet and firewall
  admin_enabled       = true
  identity {
    type = "SystemAssigned"
  }
  dynamic "georeplications" {
    for_each = var.environment == "prod" ? [1] : []  # enable georeplication for prod only
    content {
      location                = "Central US"
      zone_redundancy_enabled = true
      tags                    = {}
    }
  }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_private_endpoint" "acr_pe" {
  name                = "pe-${azurerm_container_registry.acr.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${azurerm_container_registry.acr.name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  depends_on = [ azurerm_container_registry.acr ]
}
