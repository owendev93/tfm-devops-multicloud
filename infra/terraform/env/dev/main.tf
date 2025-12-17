########################
# VARIABLES (ejemplo)
########################

variable "project_name" {
  type        = string
  default     = "tfm-microservicios"
}

variable "environment" {
  type        = string
  default     = "dev"
}

########################
# MÓDULOS AWS
########################

module "network_aws" {
  source = "../../modules/network_aws"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr_block       = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
}

module "eks" {
  source = "../../modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network_aws.vpc_id
  private_subnet_ids = module.network_aws.private_subnet_ids

  cluster_name       = "${var.project_name}-${var.environment}-eks"
  kubernetes_version = "1.29"
  desired_size       = 0  # Podemos dejar el managed node group en 0 si queremos solo self-managed
  min_size           = 0
  max_size           = 0
}

# AMI generada por Packer (por ejemplo, sacada de un .tfvars o de un data source)
variable "packer_ami_id" {
  type        = string
  description = "AMI creada con Packer para nodos EKS"
}

module "eks_selfmanaged_nodes" {
  source = "../../modules/eks_selfmanaged_nodes"

  project_name = var.project_name
  environment  = var.environment

  cluster_name = module.eks.cluster_name
  vpc_id       = module.network_aws.vpc_id
  subnet_ids   = module.network_aws.private_subnet_ids
  ami_id       = var.packer_ami_id

  instance_type     = "t3.medium"
  desired_capacity  = 2
  min_size          = 1
  max_size          = 3
  ssh_key_name      = ""   # opcional
  additional_security_group_ids = []
}


########################
# MÓDULOS AZURE
########################

module "network_azure" {
  source = "../../modules/network_azure"

  project_name = var.project_name
  environment  = var.environment

  address_space = ["10.20.0.0/16"]

  subnet_prefixes = {
    "aks"     = "10.20.1.0/24"
    "bastion" = "10.20.2.0/24"
  }

  location = "westeurope"
}

module "aks" {
  source = "../../modules/aks"

  project_name        = var.project_name
  environment         = var.environment
  location            = "westeurope"
  resource_group_name = module.network_azure.resource_group_name

  subnet_id       = module.network_azure.subnets["aks"]
  aks_cluster_name = "${var.project_name}-${var.environment}-aks"

  kubernetes_version = "1.29.0"
  node_count         = 2
  node_vm_size       = "Standard_DS2_v2"

  enable_auto_scaling = false

  enable_log_analytics            = true
  log_analytics_retention_days    = 30
  log_analytics_workspace_sku     = "PerGB2018"
}

