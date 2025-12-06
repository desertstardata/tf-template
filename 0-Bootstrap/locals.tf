locals {
  vnet = var.environment == "prod" ? "vnet-org-p" :"vnet-org-n"
  log_analytics_workspace_name = "law-org-logging-${var.environment}-01"
  log_analytics_workspace_resource_group_name = "rg-org-logging-${var.environment}"
  acr_name = "cr${var.solution_name}${var.environment}${var.instance_number}"
  app_reg_name = "ar-org-${var.solution_name}-${var.environment}"
  aks_cluster_name = "aks-${var.solution_name}-${var.environment}-${var.instance_number}"
  aks_default_pool = {
    cluster_size = var.environment == "prod" ? "Standard_D8s_v5" : "Standard_D4s_v5"
    node_pool_name = var.environment == "prod" ? "npaf" : "npaf${var.environment}"
    node_cnt = 3
    max_cnt = 10
    min_cnt = 1
  }
  aks_kubernetes_version = "1.32.2"
  resource_group_name = "rg-${var.solution_name}-${var.environment}-${var.instance_number}"
  sql_server_name = "sql-${var.solution_name}-${var.environment}-01"
  tag_app_taxonomy = "/ORG//${var.environment}-${var.solution_name}"
}