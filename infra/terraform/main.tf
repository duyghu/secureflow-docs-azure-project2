locals {
  name_prefix = "${var.project}-${var.environment}"
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.main.name
}

module "network" {
  source              = "./modules/network"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  vnet_name           = data.azurerm_virtual_network.main.name
  tags                = local.tags
}

module "database" {
  source              = "./modules/database"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = module.network.data_subnet_id
  vnet_id             = data.azurerm_virtual_network.main.id
  sql_admin_login     = var.sql_admin_login
  sql_admin_password  = var.sql_admin_password
  tags                = local.tags
}

module "app_gateway" {
  source                   = "./modules/app_gateway"
  name_prefix              = local.name_prefix
  location                 = data.azurerm_resource_group.main.location
  resource_group_name      = data.azurerm_resource_group.main.name
  app_gateway_subnet_id    = module.network.app_gateway_subnet_id
  ssl_certificate_base64   = var.appgw_ssl_certificate_base64
  ssl_certificate_password = var.appgw_ssl_certificate_password
  tags                     = local.tags
}

module "compute" {
  source                   = "./modules/compute"
  name_prefix              = local.name_prefix
  location                 = data.azurerm_resource_group.main.location
  resource_group_name      = data.azurerm_resource_group.main.name
  frontend_subnet_id       = module.network.web_subnet_id
  backend_subnet_id        = module.network.api_subnet_id
  frontend_backend_pool_id = module.app_gateway.frontend_backend_pool_id
  api_backend_pool_id      = module.app_gateway.api_backend_pool_id
  admin_username           = var.admin_username
  ssh_public_key           = var.ssh_public_key
  tags                     = local.tags
}

module "monitoring" {
  source                = "./modules/monitoring"
  name_prefix           = local.name_prefix
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  resource_group_id     = data.azurerm_resource_group.main.id
  action_email          = var.alert_email
  monthly_budget_amount = var.monthly_budget_amount
  budget_start_date     = var.budget_start_date
  app_gateway_id        = module.app_gateway.app_gateway_id
  frontend_vm_id        = module.compute.frontend_vmss_id
  backend_vm_id         = module.compute.backend_vmss_id
  sql_database_id       = module.database.sql_database_id
  tags                  = local.tags
}

module "resilience" {
  source              = "./modules/resilience"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
}
