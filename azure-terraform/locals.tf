locals {
  name = "${var.project}-${var.environment}"

  rg_name = "${local.name}-rg"

  vnet_name = "${local.name}-vnet"

  vm_name  = "${local.name}-vm"
  aks_name = "${local.name}-aks"

  storage_account_name = replace("${local.name}sa", "-", "")
  acr_name             = replace("${local.name}acr", "-", "")
  keyvault_name        = "${local.name}-kv"
  ml_workspace_name    = "${local.name}-mlw"

  tags = {
    Project = var.project
    Env     = var.environment
  }

}
