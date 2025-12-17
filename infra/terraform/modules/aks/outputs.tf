output "aks_id" {
  description = "ID del clúster AKS"
  value       = azurerm_kubernetes_cluster.this.id
}

output "aks_name" {
  description = "Nombre del clúster AKS"
  value       = azurerm_kubernetes_cluster.this.name
}

output "aks_fqdn" {
  description = "FQDN del servidor API de AKS"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "aks_node_resource_group" {
  description = "Resource Group de los nodos de AKS"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kube_config_raw" {
  description = "kubeconfig (usuario) para conectarse al clúster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "kubeconfig (admin) para conectarse al clúster"
  value       = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID del workspace de Log Analytics (si está habilitado)"
  value       = try(azurerm_log_analytics_workspace.this[0].id, null)
}
