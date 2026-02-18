
resource "azurerm_application_insights" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_machine_learning_workspace" "this" {
  name = var.workspace_name
  location = var.location
  resource_group_name = var.resource_group_name
  storage_account_id = var.storage_account_id
  key_vault_id = var.key_vault_id
  application_insights_id = azurerm_application_insights.this.id
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}