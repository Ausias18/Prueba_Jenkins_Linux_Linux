provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  subscription_id = "2de9d718-d170-4e29-af3b-60c30e449b3c"
  tenant_id = "ece33831-9bc7-4217-a330-2082dfa1a525"
  client_id = "15055b44-7983-416f-823f-99c4e348dfe7"
  client_secret = "7b7af9ec-d750-4ed0-9d2e-cb7a30ec3575"
  features {}
}
