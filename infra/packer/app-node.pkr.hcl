packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = ">= 1.4.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "project_name" {
  type    = string
  default = "tfm-microservicios"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "azure_location" {
  type    = string
  default = "westeurope"
}

locals {
  image_version = "1.0.0"
}

# BUILDER AWS
source "amazon-ebs" "aws_node" {
  region        = var.aws_region
  instance_type = "t3.medium"
  ami_name      = "${var.project_name}-${var.environment}-eks-node-${local.image_version}"

  source_ami_filter {
    filters = {
      name                = "amazon-eks-node-*-x86_64-*" # patrón de AMI optimizada para EKS
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["602401143452"] # Cuenta oficial de AMIs de EKS
    most_recent = true
  }

  ssh_username                  = "ec2-user"
  associate_public_ip_address   = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Packer"
    Role        = "eks-node"
  }
}


# BUILDER AZURE
source "azure-arm" "azure_node" {
  managed_image_resource_group_name = "${var.project_name}-${var.environment}-images-rg"
  managed_image_name                = "${var.project_name}-${var.environment}-node-${local.image_version}"

  location = var.azure_location

  vm_size           = "Standard_DS2_v2"
  os_type           = "Linux"
  image_publisher   = "Canonical"
  image_offer       = "0001-com-ubuntu-server-focal"
  image_sku         = "20_04-lts-gen2"
  azure_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Packer"
  }

  # Aquí deberás configurar: subscription_id, client_id, client_secret, tenant_id
  # o usar Managed Identity si corres Packer dentro de Azure.
}

build {
  name = "${var.project_name}-${var.environment}-node-image"

  sources = [
    "source.amazon-ebs.aws_node",
    "source.azure-arm.azure_node",
  ]

  provisioner "shell" {
    script = "scripts/setup-node.sh"
  }
}
