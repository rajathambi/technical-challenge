terraform {
  
  # storing the terraform state file in the azure storage
  backend "azurerm" {
    
    resource_group_name  = "rg-t-three-tier-app"
    storage_account_name = "iactstoracc"
    container_name       = "t-tfstate"
    key                  = "test.terraform.tfstate"
    
  }
}