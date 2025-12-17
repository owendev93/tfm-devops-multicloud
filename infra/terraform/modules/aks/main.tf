locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

########################
# LOG ANALYTICS (OPCIONAL)
########################

resource "azurerm_log_analytics_workspace" "this" {
  count = var.enable_log_analytics ? 1 : 0

  name                = "${var.project_name}-${var.environment}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_days

  tags = local.common_tags
}

########################
# CLÚSTER AKS
########################

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_name}-${var.environment}-aks"

  kubernetes_version = var.kubernetes_version

  # Identidad gestionada (recomendado)
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "system"
    vm_size    = var.node_vm_size
    node_count = var.node_count
    vnet_subnet_id = var.subnet_id

    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null

    # etiquetado de nodos
    node_labels = {
      Environment = var.environment
      Pool        = "system"
    }
  }

  # Perfil de red: usamos CNI de Azure (más común hoy en día)
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  # RBAC habilitado
  role_based_access_control_enabled = true

  # Integración con Log Analytics (si está habilitado)
  dynamic "oms_agent" {
    for_each = var.enable_log_analytics ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.this[0].id
    }
  }

  # Opcional: habilitar local account / kube admin (útil para labs / TFM)
  local_account_disabled = false

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}
