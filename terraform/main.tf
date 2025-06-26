provider "azurerm" {
    subscription_id = "2b3b091c-aa6e-4fa2-9f52-561cfed1aa19"
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "billing-rg"
  location = "East US"
}

resource "azurerm_storage_account" "archive" {
  name                     = "billingarchive${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "azurerm_storage_container" "archive_container" {
  name                  = "billing-archive"
  storage_account_name  = azurerm_storage_account.archive.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_service_plan" "function" {
  name                = "billing-function-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_function_app" "archiver" {
  name                       = "billing-archiver-func"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.function.id
  storage_account_name       = azurerm_storage_account.archive.name
  storage_account_access_key = azurerm_storage_account.archive.primary_access_key
  site_config {
    application_stack {
      python_version = "3.10"
    }
  }
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "AzureWebJobsStorage"      = azurerm_storage_account.archive.primary_connection_string
    "ARCHIVE_CONTAINER"        = azurerm_storage_container.archive_container.name
    # Add Cosmos DB keys and URI as needed
  }
}
