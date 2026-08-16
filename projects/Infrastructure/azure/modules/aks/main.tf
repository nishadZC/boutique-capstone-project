resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2pds_v5"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  ingress_application_gateway {
    gateway_id = var.app_gateway_id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }
}
