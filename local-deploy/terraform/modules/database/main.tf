# Definición de recursos de persistencia

# Secreto opaco para credenciales de base de datos
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = "default"
  }
  data = {
    username = "petclinic"
    password = "petclinic"
  }
  type = "Opaque"
}

# Servicio Headless para descubrimiento DNS interno
resource "kubernetes_service" "mysql_db" {
  metadata {
    name      = "mysql-db"
    namespace = "default"
  }
  spec {
    port {
      port        = 3306
      target_port = 3306
    }
    selector = {
      app = "mysql"
    }
    cluster_ip = "None"
  }
}

# Despliegue de instancia única de MySQL 5.7
resource "kubernetes_deployment" "mysql_db" {
  metadata {
    name      = "mysql-db"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"
          
          # Configuración de entorno MySQL
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "root"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "petclinic"
          }
          # Inyección de credenciales desde Secret
          env {
            name = "MYSQL_USER"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "username"
              }
            }
          }
          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "password"
              }
            }
          }
          port {
            container_port = 3306
            name           = "mysql"
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        # Volumen efímero para entorno local
        volume {
          name = "mysql-data"
          empty_dir {}
        }
      }
    }
  }
}