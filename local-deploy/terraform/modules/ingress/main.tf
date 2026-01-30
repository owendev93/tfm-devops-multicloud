# Definición de recursos de red y enrutamiento

# Servicio NodePort para fijar el puerto de entrada del Ingress Controller
resource "kubernetes_service" "ingress_nodeport_fixed" {
  metadata {
    name      = "ingress-nginx-controller-fixed"
    namespace = "ingress-nginx"
  }
  spec {
    type = "NodePort"
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = "http"
      node_port   = 30080
    }
    selector = {
      "app.kubernetes.io/name"      = "ingress-nginx"
      "app.kubernetes.io/component" = "controller"
    }
  }
}

# Configuración de reglas de Ingress para arquitectura Strangler Fig
resource "kubernetes_ingress_v1" "strangler" {
  metadata {
    name      = "petclinic-strangler-ingress"
    namespace = "default"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        # Regla de enrutamiento para microservicio Vets
        path {
          path      = "/vets.html"
          path_type = "Prefix"
          backend {
            service {
              name = "petclinic-vets"
              port {
                number = 8080
              }
            }
          }
        }
        # Regla de enrutamiento por defecto (Monolito)
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "petclinic-monolith"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}