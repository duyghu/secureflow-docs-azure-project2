resource "azurerm_bastion_host" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Developer"
  virtual_network_id  = var.virtual_network_id
  copy_paste_enabled  = true
  tags                = var.tags
}
