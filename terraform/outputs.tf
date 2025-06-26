output "archive_blob_url" {
  value = "https://${azurerm_storage_account.archive.name}.blob.core.windows.net/${azurerm_storage_container.archive_container.name}"
}
