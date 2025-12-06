resource "azurerm_role_assignment" "aks_acr_role" {
  principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope = azurerm_resource_group.rg.id
}

locals {
  flattened_personas = distinct(flatten([
    for persona in var.azure_personas : (
      [
        for pair in setproduct(persona.members, persona.roles) : {
#          persona = persona.persona
          member  = pair[0]
          role    = pair[1]
        }
      ]
    )
  ]))
}

output "flattened_personas" {
  value = local.flattened_personas
}

# Data sources for resolving principal IDs
data "azuread_user" "users" {
  for_each = {
    for member in distinct([
      for entry in local.flattened_personas : entry.member
      if startswith(entry.member, "user:")
    ]) : member => member
  }

  user_principal_name = replace(each.key, "user:", "")
}

data "azuread_group" "groups" {
  for_each = {
    for member in distinct([
      for entry in local.flattened_personas : entry.member
      if startswith(entry.member, "group:")
    ]) : member => member
  }

  display_name = replace(each.key, "group:", "")
}

data "azuread_service_principal" "sps" {
  for_each = {
    for member in distinct([
      for entry in local.flattened_personas : entry.member
      if startswith(entry.member, "servicePrincipal:")
    ]) : member => member
  }

  display_name = replace(each.key, "servicePrincipal:", "")
}

data "azurerm_user_assigned_identity" "managed_identities" {
  for_each = {
    for member in distinct([
      for entry in local.flattened_personas : replace(entry.member, "managedIdentity:", "")
      if startswith(entry.member, "managedIdentity:")
    ]) : member => member
  }

  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
}

# Role assignments
resource "azurerm_role_assignment" "persona_assignments" {
  for_each = {
    for entry in local.flattened_personas : 
    "${entry.member}-${entry.role}" => {
      role_definition_name = entry.role
      principal_id = (
        startswith(entry.member, "user:") ? data.azuread_user.users[entry.member].object_id :
        startswith(entry.member, "group:") ? data.azuread_group.groups[entry.member].object_id :
        startswith(entry.member, "servicePrincipal:") ? data.azuread_service_principal.sps[entry.member].object_id :
        startswith(entry.member, "managedIdentity:") ? data.azurerm_user_assigned_identity.managed_identities[replace(entry.member, "managedIdentity:", "")].principal_id :
        startswith(entry.member, "id:") ? replace(entry.member, "id:", "") :
        null
      )
    }
  }

  scope                = azurerm_resource_group.rg.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [azurerm_resource_group.rg]
}