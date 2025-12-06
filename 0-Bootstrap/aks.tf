resource "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  name = local.aks_cluster_name
  dns_prefix = var.environment != "prod" ? "${var.solution_name}-${var.environment}" : var.solution_name
  automatic_upgrade_channel = "node-image"
  support_plan = "AKSLongTermSupport"
  role_based_access_control_enabled = true
  sku_tier = "Premium"
  api_server_access_profile {
    authorized_ip_ranges = [
      "10.0.0.0/16"
    ]
  }
  maintenance_window_node_os {
    day_of_week = "Monday"
    duration = 8
    frequency = "RelativeMonthly"
    interval = 1
    week_index = var.environment == "dev" ? "First" : var.environment == "qa" ? "Second" : "Third"
    start_time = "20:00"
    utc_offset = "-05:00"
  }
  maintenance_window_auto_upgrade {
    day_of_week = "Tuesday"
    duration = 8
    frequency = "RelativeMonthly"
    interval = 1
    week_index = var.environment == "dev" ? "First" : var.environment == "qa" ? "Second" : "Third"
    start_time = "20:00"
    utc_offset = "-05:00"
  }
  default_node_pool {
    name = local.aks_default_pool.node_pool_name
    # node_count = local.aks_default_pool.node_cnt  # only supported when autoscaling is false
    max_count = local.aks_default_pool.max_cnt
    min_count = local.aks_default_pool.min_cnt
    auto_scaling_enabled = true
    vm_size = local.aks_default_pool.cluster_size
    # Enable VNET Injection
    vnet_subnet_id = data.azurerm_subnet.snet_k8s.id
    temporary_name_for_rotation = "nptemp"
    # multi-zone intentionally disabled because the airflow helm manifest  does not support custom storage driver for PVs with all deployments.
    # zones = var.environment == "prod" ? [1,2,3] : [1]
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  identity {
    type = "SystemAssigned"
  }
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = false
    admin_group_object_ids = data.azuread_groups.do_admins.object_ids
  }
  network_profile {
    network_plugin = "azure"
    network_plugin_mode = "overlay"
    pod_cidr = "10.244.0.0/16"
    service_cidr = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }
  kubernetes_version = local.aks_kubernetes_version
  oidc_issuer_enabled = true
  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
    msi_auth_for_monitoring_enabled = true
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "2m"
  }
  local_account_disabled = false
  private_cluster_enabled = false
  depends_on = [ 
    data.azurerm_virtual_network.vnet,
    data.azurerm_subnet.snet_k8s,
    azurerm_container_registry.acr
  ]
}