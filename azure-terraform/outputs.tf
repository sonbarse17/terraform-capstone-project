output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "aks_name" {
  value = module.aks.aks_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "ml_workspace_name" {
  value = module.ml_workspace.workspace_name
}