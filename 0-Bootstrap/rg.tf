resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.deployment_location

  tags = {
    AppTaxonomy          = local.tag_app_taxonomy
    AppOwner             = "ownerid"
    DataClassification   = "PHI/HIPAA"
    SecurityClassification = ""
    Billing              = "BILLINGCODE"
    Project              = var.solution_name
    Environment          = var.environment
    OperationsTeam       = "Operations@ORG.org"
    AppTier              = "Tier 1"
    DR                   = "No"
    BackupRequirement    = "No"
    MaintenanceWindow    = "Every Thursday at 8PM"
    LifeExpectancy       = "5 Years"
    CreationDate         = var.tag_creation_date
    Ticket               = "N/A"
  }
}

resource "azurerm_management_lock" "lock_rg" {
  name               = "lock-rg"
  scope              = azurerm_resource_group.rg.id
  lock_level         = "CanNotDelete" # or "ReadOnly"
  notes              = "Prevent accidental deletion"
  depends_on = [ azurerm_resource_group.rg ]
}
