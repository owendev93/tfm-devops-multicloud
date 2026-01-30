# Definición de variables del módulo Petclinic

variable "docker_registry" { type = string }
variable "image_name" { type = string }
variable "image_digest" { type = string }
variable "chart_path" { type = string }
variable "values_local_path" { type = string }
variable "values_vets_path" { type = string }