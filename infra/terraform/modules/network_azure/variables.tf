variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnet_prefixes" {
  description = "Mapa nombre -> prefijo de subnet"
  type        = map(string)
}
