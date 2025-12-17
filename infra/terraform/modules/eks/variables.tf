variable "project_name" {
  description = "Nombre del proyecto (para tags y nombres de recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, pre, prod, etc.)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará el clúster EKS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para los nodos del clúster"
  type        = list(string)
}

variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para el clúster EKS"
  type        = string
  default     = "1.29"
}

variable "desired_size" {
  description = "Tamaño deseado del node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Tamaño mínimo del node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Tamaño máximo del node group"
  type        = number
  default     = 3
}

variable "instance_types" {
  description = "Lista de tipos de instancia para los nodos"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Tipo de capacidad (ON_DEMAND o SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "enabled_cluster_log_types" {
  description = "Tipos de logs de EKS a enviar a CloudWatch"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "tags" {
  description = "Tags adicionales a aplicar"
  type        = map(string)
  default     = {}
}
