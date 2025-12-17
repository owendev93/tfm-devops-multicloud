variable "project_name" {
  description = "Nombre del proyecto (para tags y nombres de recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, pre, prod, etc.)"
  type        = string
}

variable "location" {
  description = "Región de Azure donde se desplegará AKS"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group donde se creará el clúster AKS"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subnet donde se integrará el clúster AKS"
  type        = string
}

variable "aks_cluster_name" {
  description = "Nombre del clúster AKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para AKS (ejemplo: 1.29.0)"
  type        = string
  default     = "1.29.0"
}

variable "node_count" {
  description = "Número de nodos en el pool por defecto"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "Tamaño de las VMs del node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "enable_auto_scaling" {
  description = "Habilitar autoscaling para el node pool"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Número mínimo de nodos cuando autoscaling está habilitado"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Número máximo de nodos cuando autoscaling está habilitado"
  type        = number
  default     = 3
}

variable "enable_log_analytics" {
  description = "Crear e integrar Log Analytics con AKS"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_sku" {
  description = "SKU de Log Analytics (ej: PerGB2018)"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Días de retención de logs en Log Analytics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags adicionales a aplicar"
  type        = map(string)
  default     = {}
}
