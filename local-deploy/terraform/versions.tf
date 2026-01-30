# Configuración de versiones y proveedores de Terraform

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Configuración del proveedor Kubernetes (In-Cluster Config automático)
provider "kubernetes" {}

# Configuración del proveedor Helm (Hereda contexto de Kubernetes)
provider "helm" {
  kubernetes {
    config_path = ""
  }
}