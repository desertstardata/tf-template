resource "azurerm_key_vault" "kv" {
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  name                      = "kv-${var.solution_name}-${var.environment}-${var.instance_number}"
  sku_name                  = "standard"    # The enhanced security features in premium are not currently required.
  rbac_authorization_enabled = true
  tenant_id                 = var.tenant_id
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [
      "10.0.0.0/16"
    ]
    virtual_network_subnet_ids = [
      data.azurerm_subnet.snet_transit.id
    ]
  }

  depends_on = [ 
    azurerm_resource_group.rg,
    data.azurerm_subnet.snet_transit
  ]
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-${azurerm_key_vault.kv.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${azurerm_key_vault.kv.name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  depends_on = [ azurerm_key_vault.kv ]
}

# resource "azurerm_key_vault_key" "cmk" {
#   name         = "cmk-key"
#   key_vault_id = data.azurerm_key_vault.orgroot_kv.id
#   key_type     = "RSA"
#   key_size     = 2048
#   expiration_date = timeadd(timestamp(), "8760h") # 1 year.

#   rotation_policy {
#     expire_after = "P1Y"

#     lifetime_action {
#       action            = "Rotate"
#       time_after_create = "P6M" # Rotate after 6 months
#     }
#   }
# }
