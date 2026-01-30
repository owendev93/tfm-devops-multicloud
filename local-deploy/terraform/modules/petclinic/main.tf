# Definición de releases de Helm para la aplicación

# Release: Monolito (Tráfico general)
resource "helm_release" "monolith" {
  name       = "petclinic-tfm"
  namespace  = "default"
  chart      = var.chart_path
  
  values = [
    file(var.values_local_path)
  ]

  # Sobrescritura de valores para inyección de imagen inmutable
  set {
    name  = "image.repository"
    value = "${var.docker_registry}/${var.image_name}"
  }
  set {
    name  = "image.digest"
    value = var.image_digest
  }
  set {
    name  = "autoscaling.enabled"
    value = "false"
  }
}

# Release: Microservicio Vets (Tráfico segregado)
resource "helm_release" "vets" {
  name       = "petclinic-vets"
  namespace  = "default"
  chart      = var.chart_path

  values = [
    file(var.values_vets_path)
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_registry}/${var.image_name}"
  }
  set {
    name  = "image.digest"
    value = var.image_digest
  }
  set {
    name  = "autoscaling.enabled"
    value = "false"
  }
}