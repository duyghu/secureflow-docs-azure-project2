resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.6.0/26"]
}

# The subscription has reached the West Europe public IP quota. The Bastion subnet
# is provisioned so Bastion can be enabled as soon as quota is raised or a project
# public IP is freed.
