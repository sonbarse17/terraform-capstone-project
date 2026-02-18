provider "azurerm" {
  features {}
  subscription_id = "c2b10946-e5f1-48eb-b77c-5c787ab12b90"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

module "vnet" {
  source              = "./modules/vnet"
  vnet_name           = local.vnet_name
  address_space       = var.vnet_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "storage" {
  source              = "./modules/storage-accounts"
  account_name        = local.storage_account_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = local.acr_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "keyvault" {
  source              = "./modules/keyvault"
  keyvault_name       = local.keyvault_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "vm" {
  source              = "./modules/vm"
  vm_name             = local.vm_name
  vm_size             = var.vm_size
  subnet_id           = module.vnet.public_subnet_ids[0]
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}

module "aks" {
  source              = "./modules/aks"
  aks_name            = local.aks_name
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
  subnet_id           = module.vnet.private_subnet_ids[0]
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  acr_id              = module.acr.acr_id
  tags                = local.tags
}

module "ml_workspace" {
  source              = "./modules/azure-ml-workspace"
  workspace_name      = local.ml_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  storage_account_id  = module.storage.storage_account_id
  key_vault_id        = module.keyvault.keyvault_id
  tags                = local.tags
}