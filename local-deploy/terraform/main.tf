# Orquestador principal de infraestructura para el entorno local
# Gestiona el ciclo de vida de los módulos de persistencia, aplicación y red

# 1. Módulo de Persistencia
module "database" {
  source = "./modules/database"
}

# 2. Módulo de Aplicación
module "petclinic" {
  source = "./modules/petclinic"

  # Inyección de variables globales al módulo
  docker_registry = var.docker_registry
  image_name      = var.image_name
  image_digest    = var.image_digest
  
  # Definición de rutas relativas al directorio de ejecución del módulo raíz
  chart_path        = "../../deploy/apps/helm/apps"
  values_local_path = "../petclinic/values-local.yaml"
  values_vets_path  = "../petclinic/values-vets.yaml"

  # Dependencia explícita para asegurar la disponibilidad de la base de datos
  depends_on = [module.database]
}

# 3. Módulo de Red
module "ingress" {
  source = "./modules/ingress"

  # Dependencia explícita para asegurar la existencia de los servicios backend
  depends_on = [module.petclinic]
}