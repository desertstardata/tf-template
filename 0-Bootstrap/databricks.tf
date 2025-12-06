resource "azurerm_databricks_workspace" "dbw" {
  name = "dbw-${var.solution_name}-${var.environment}-${var.instance_number}"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku = "premium"    # required for enhanced security and governance, including IP Access lists
  managed_resource_group_name = "rg-${var.solution_name}dbw-${var.environment}-01"
  public_network_access_enabled = true
  custom_parameters {
    virtual_network_id = data.azurerm_virtual_network.vnet.id
    public_subnet_name = data.azurerm_subnet.snet_adb_public.name
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsg_dbw.id
    private_subnet_name = data.azurerm_subnet.snet_adb_private.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsg_private.id
  }
  enhanced_security_compliance {
    enhanced_security_monitoring_enabled = true
    automatic_cluster_update_enabled = true
    compliance_security_profile_enabled = true
    compliance_security_profile_standards = [ 
      "HIPAA",
      #"PCI_DSS",  # doesn't support serverless compute
      #"HITRUST",  # doesn't support serverless compute, expensive, terraform bug
    ]
  }
  depends_on = [ 
    data.azurerm_subnet.snet_adb_private,
    data.azurerm_subnet.snet_adb_public,
    data.azurerm_subnet.snet_transit,
    azurerm_network_security_rule.nsr-worker-to-databricks-cp,
    azurerm_network_security_rule.nsr-worker-to-eventhub,
    azurerm_network_security_rule.nsr-worker-to-sql,
    azurerm_network_security_rule.nsr-worker-to-storage,
    azurerm_network_security_rule.nsr-worker-to-worker-inbound,
    azurerm_network_security_rule.nsr-worker-to-worker-outbound
  ]
}