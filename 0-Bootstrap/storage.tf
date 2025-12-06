resource "azurerm_storage_account" "sa" {
  for_each = {
    for sa in var.storage_accounts : 
    "asa${var.solution_name}${sa.base_name}${var.environment}" => sa
  }

  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"      # Enhanced performance and features of higher tiers aren't reqired
  account_replication_type = var.environment == "prod" ? "ZRS" : "LRS" # prod is ZRS for HA
  account_kind             = "StorageV2"     # required for ADLS
  is_hns_enabled           = true            # required for ADLS
  allow_nested_items_to_be_public = false    # sets the policy that prevents anonymous access

  network_rules {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = ["10.0.0.0/16"]
    virtual_network_subnet_ids = [
      data.azurerm_subnet.snet_adb_private.id,
      data.azurerm_subnet.snet_adb_public.id,
      data.azurerm_subnet.snet_k8s.id,
      data.azurerm_subnet.snet_transit.id
    ]
  }

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_storage_container" "sac" {
  for_each = merge([
    for sa in var.storage_accounts : {
      for container in sa.containers :
      "asa${var.solution_name}${sa.base_name}${var.environment}-${container}" => {
        storage_account_name = "asa${var.solution_name}${sa.base_name}${var.environment}"
        container_name       = container
      }
    }
  ]...)

  name                  = each.value.container_name
  storage_account_id    = azurerm_storage_account.sa[each.value.storage_account_name].id
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "sa_blob_pe" {
  for_each = azurerm_storage_account.sa

  name                = "pe-${each.key}-blob"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${each.key}-blob"
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  depends_on = [azurerm_storage_account.sa]
}

resource "azurerm_private_endpoint" "sa_dfs_pe" {
  for_each = azurerm_storage_account.sa

  name                = "pe-${each.key}-dfs"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = data.azurerm_subnet.snet_transit.id

  private_service_connection {
    name                           = "psc-${each.key}-dfs"
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  depends_on = [azurerm_storage_account.sa]
}