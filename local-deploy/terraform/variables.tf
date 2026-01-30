# Definición de variables de entrada globales

variable "docker_registry" {
  description = "Registro de contenedores Docker origen"
  type        = string
  default     = "jolrojasbodev"
}

variable "image_name" {
  description = "Identificador de la imagen de la aplicación"
  type        = string
  default     = "spring-petclinic"
}

variable "image_digest" {
  description = "Digest SHA256 de la imagen para despliegue inmutable (Suministrado por CI)"
  type        = string
}