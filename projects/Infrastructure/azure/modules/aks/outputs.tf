output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "ingress_application_gateway_identity" {
  value = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
