resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "postgres" {
  name                 = "postgres-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.3.0/24"]
  delegation {
    name = "fs"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

module "app_gateway" {
  source              = "../../modules/app_gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  app_gateway_name    = "${var.prefix}-appgw"
  vnet_name           = azurerm_virtual_network.vnet.name
  subnet_id           = azurerm_subnet.appgw.id
}

module "aks" {
  source              = "../../modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = "${var.prefix}-aks"
  dns_prefix          = "${var.prefix}-aks"
  subnet_id           = azurerm_subnet.aks.id
  app_gateway_id      = module.app_gateway.id
}


module "postgres" {
  source              = "../../modules/postgres"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = "${var.prefix}-pg"
  admin_username      = "postgres"
  admin_password      = var.db_password
  vnet_id             = azurerm_virtual_network.vnet.id
  subnet_id           = azurerm_subnet.postgres.id
}

data "azurerm_client_config" "current" {}

module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  keyvault_name       = "${var.prefix}-kv"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}
