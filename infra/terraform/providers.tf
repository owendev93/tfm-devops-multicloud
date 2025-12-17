# Backend remoto para Terraform (ejemplo AWS S3 + DynamoDB)
terraform {
    backend "s3" {
    bucket         = "tfm-owen-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tfm-owen-terraform-lock"
    encrypt        = true
    }
}

provider "aws" {
    region = var.aws_region
}

provider "azurerm" {
    features {}
}
