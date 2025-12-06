resource "random_password" "sql_admin_password" {
  length  = 20
  special = true
}

# Write secret to DO keyvault. Key name is the SQL server name.
resource "azurerm_key_vault_secret" "sql_password_secret" {
  name         = azurerm_mssql_server.sql_server.name
  value        = random_password.sql_admin_password.result
  key_vault_id = data.azurerm_key_vault.do_kv.id
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = local.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  # Version is always 12.0 for AzureSQL and is required by Terraform as a placeholder. The sub-version (Example: 17.5) is managed by Microsoft and not configurable.
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql_admin_password.result
}

resource "azurerm_mssql_database" "sql_db" {
  name       = var.database_name
  server_id  = azurerm_mssql_server.sql_server.id
  # SKU Codes for performance, availibility and redundancy. Business Critical almost doubles the cost cs General Purpose.
  sku_name   = var.environment == "prod" ? "GP_Gen5_4" : "GP_Gen5_2"
  zone_redundant = var.environment == "prod" ? true : false  # Increases resiliency with low incremental cost (about 50% more)
}

resource "azurerm_mssql_firewall_rule" "allow_all" {
  name         = "AllowAll"
  server_id    = azurerm_mssql_server.sql_server.id
  start_ip_address = "10.0.0.0"
  end_ip_address   = "10.0.0.254"
}

resource "azurerm_mssql_firewall_rule" "allow_microsoft_services" {
  name      = "AllowMicrosoftServices"
  server_id = azurerm_mssql_server.sql_server.id

  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "sql_server_name" {
  value = azurerm_mssql_server.sql_server.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_db.name
}

resource "azurerm_private_endpoint" "sql_server_pe" {
  name                = "pe-${azurerm_mssql_server.sql_server.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${azurerm_mssql_server.sql_server.name}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  depends_on = [azurerm_mssql_server.sql_server]
}
