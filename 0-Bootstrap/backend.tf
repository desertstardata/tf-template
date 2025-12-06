terraform {
  backend "azurerm" {
    resource_group_name = "rg-org-name-all"
    storage_account_name = "saorgtf01"
    container_name = "tf01"
    key = "template01.dev.tfstate"  # set this to ${solution_name}${instance_number}.${environment}.tfstate
  }
}
