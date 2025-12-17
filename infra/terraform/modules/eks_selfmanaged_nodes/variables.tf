variable "project_name" {
  description = "Nombre del proyecto (para tags y nombres de recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, pre, prod, etc.)"
  type        = string
}

variable "cluster_name" {
  description = "Nombre del clúster EKS al que se unirán los nodos"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets (normalmente privadas) donde se desplegarán los nodos"
  type        = list(string)
}

variable "ami_id" {
  description = "ID de la AMI personalizada creada con Packer"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia para los nodos"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Número deseado de instancias en el grupo de autoescalado"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Número mínimo de instancias en el ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Número máximo de instancias en el ASG"
  type        = number
  default     = 3
}

variable "ssh_key_name" {
  description = "Nombre del par de claves para acceso SSH (opcional)"
  type        = string
  default     = ""
}

variable "additional_security_group_ids" {
  description = "Security Groups adicionales para los nodos (además del propio del módulo)"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID de la VPC (para crear el security group de nodos)"
  type        = string
}

variable "tags" {
  description = "Tags adicionales a aplicar"
  type        = map(string)
  default     = {}
}
