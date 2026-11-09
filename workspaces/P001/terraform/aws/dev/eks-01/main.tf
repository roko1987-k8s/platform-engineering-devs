
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.20.0"
    }
  }
}

# AWS Account ID recibido desde Terraform Agent.
# Origen: .env -> TF_VAR_aws_account_id
variable "aws_account_id" {
  description = "Cuenta AWS autorizada para el aprovisionamiento"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id debe contener exactamente 12 dígitos."
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "git::https://github.com/roko1987-k8s/platform-engineering-modules-tfc.git//aws/dev/eks?ref=main"

  # Identidad y configuración
  team_id            = "P001"
  application_code   = "adp-eks"
  environment        = "dev"
  region             = "us-east-1"
  sequence           = 1
  kubernetes_version = "1.35"

  # Catálogo de capacidad
  system_size = "M"
  user_size   = "M"

  node_counts = {
    system = {
      minimum = 1
      desired = 1
      maximum = 2
    }

    user = {
      minimum = 1
      desired = 1
      maximum = 2
    }
  }

  # Fase 1: aprovisionamiento exclusivo de Networking.
  proposal_mode = "NETWORKING_ONLY"
  
  reviewed_execution = {
    # Nunca almacenar el Account ID real en GitHub.
    aws_account_id = var.aws_account_id

    networking = {
      vpc_cidr = "10.100.0.0/16"

      cluster_subnet_cidrs = [
        "10.100.0.0/24",
        "10.100.1.0/24"
      ]

      node_subnet_cidrs = [
        "10.100.10.0/24",
        "10.100.11.0/24"
      ]

      public_subnet_cidrs = [
        "10.100.20.0/24"
      ]

      approval_reference = "LAB-P001-001"
      connectivity       = null
    }
  }
}
