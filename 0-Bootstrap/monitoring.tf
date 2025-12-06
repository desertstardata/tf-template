resource "azurerm_monitor_diagnostic_setting" "dbw_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-dbw-${var.solution_name}-${var.environment}"
  target_resource_id = azurerm_databricks_workspace.dbw.id
  enabled_log {
    category_group = "AllLogs"
  }
  depends_on = [ azurerm_databricks_workspace.dbw ]
}

resource "azurerm_monitor_diagnostic_setting" "df_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-df-${var.solution_name}-${var.environment}"
  target_resource_id = azurerm_data_factory.df.id
  enabled_log {
    category_group = "AllLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [ azurerm_data_factory.df ]
}

resource "azurerm_monitor_diagnostic_setting" "kv_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-kv-${var.solution_name}-${var.environment}"
  target_resource_id = azurerm_key_vault.kv.id
  enabled_log {
    category_group = var.environment == "prod" ? "allLogs" : "audit"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [ azurerm_key_vault.kv ]
}

resource "azurerm_monitor_diagnostic_setting" "vnet_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-vnet-${var.solution_name}-${var.environment}"
  target_resource_id = data.azurerm_virtual_network.vnet.id
  enabled_log {
    category_group = "AllLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [ data.azurerm_virtual_network.vnet ]
}

resource "azurerm_monitor_diagnostic_setting" "sa_monitoring" {
  for_each = {
    for sa in var.storage_accounts :
    "asa${var.solution_name}${sa.base_name}${var.environment}" => sa
  }

  name                       = "diag-sa-org-${each.key}-${var.environment}"
  target_resource_id         = azurerm_storage_account.sa[each.key].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id

  enabled_metric {
    category = "Transaction"
  }

  depends_on = [azurerm_storage_account.sa]
}

resource "azurerm_monitor_diagnostic_setting" "sa_blob_monitoring" {
  for_each = {
    for sa in var.storage_accounts :
    "asa${var.solution_name}${sa.base_name}${var.environment}" => sa
  }

  name                       = "diag-sa-org-blob-${each.key}-${var.environment}"
  target_resource_id         = "${azurerm_storage_account.sa[each.key].id}/blobServices/default"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id

  enabled_log {
    category_group = var.environment == "prod" ? "allLogs" : "audit"
  }

  enabled_metric {
    category = "Transaction"
  }

  depends_on = [azurerm_storage_account.sa]
}

resource "azurerm_monitor_diagnostic_setting" "aks_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-aks-${var.solution_name}-${var.environment}"
  target_resource_id = azurerm_kubernetes_cluster.aks.id
  enabled_log {
    category = "kube-apiserver"
  }
  enabled_log {
    category = "kube-audit"
  }
  enabled_log {
    category = "kube-audit-admin"
  }
  enabled_log {
    category = "kube-controller-manager"
  }
  enabled_log {
    category = "kube-scheduler"
  }
  enabled_log {
    category = "cluster-autoscaler"
  }
  enabled_log {
    category = "cloud-controller-manager"
  }
  enabled_log {
    category = "guard"
  }
  enabled_log {
    category = "csi-azuredisk-controller"
  }
  enabled_log {
    category = "csi-azurefile-controller"
  }
  enabled_log {
    category = "csi-snapshot-controller"
  }
  enabled_log {
    category = "fleet-member-agent"
  }
  enabled_log {
    category = "fleet-member-net-controller-manager"
  }
  enabled_log {
    category = "fleet-mcs-controller-manager"
  }
  enabled_log {
    category = "karpenter-events"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

resource "azurerm_monitor_diagnostic_setting" "acr_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-acr-${var.solution_name}-${var.environment}"
  target_resource_id = azurerm_container_registry.acr.id
  enabled_log {
    category_group = var.environment == "prod" ? "allLogs" : "audit"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [ azurerm_container_registry.acr ]
}

resource "azurerm_monitor_diagnostic_setting" "nsg_monitoring" {
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  name = "diag-nsg-${var.solution_name}-${var.environment}"
  target_resource_id = azurerm_network_security_group.nsg.id
  enabled_log {
    category_group = "allLogs"
  }
  depends_on = [ azurerm_network_security_group.nsg ]
}

resource "azurerm_monitor_diagnostic_setting" "sql_db_monitoring" {
  name                       = "diag-sqldb-${var.solution_name}-${var.environment}"
  target_resource_id         = azurerm_mssql_database.sql_db.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "Basic"
  }
  enabled_metric {
    category = "InstanceAndAppAdvanced"
  }
  enabled_metric {
    category = "WorkloadManagement"
  }
  depends_on = [azurerm_mssql_database.sql_db]
}
