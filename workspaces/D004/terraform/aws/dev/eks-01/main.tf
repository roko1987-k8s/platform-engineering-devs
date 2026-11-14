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

# Networking asignado por la plataforma (GP02, registro central).
# Origen: Terraform Agent -> TF_VAR_network; nunca se escribe a mano.
variable "network" {
  description = "Segmento de red del workspace asignado automáticamente"
  type = object({
    vpc_cidr             = string
    cluster_subnet_cidrs = list(string)
    node_subnet_cidrs    = list(string)
    public_subnet_cidrs  = list(string)
    approval_reference   = string
  })
  nullable = false
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "git::https://github.com/roko1987-k8s/platform-engineering-modules-tfc.git//aws/dev/eks?ref=main"

  team_id            = "D004"
  application_code   = "adp-eks"
  environment        = "dev"
  region             = "us-east-1"
  sequence           = 1
  kubernetes_version = "1.35"

  system_size = "M"
  user_size   = "S"

  node_counts = {
    system = {
      minimum = 1
      desired = 1
      maximum = 2
    }
    user = {
      minimum = 1
      desired = 1
      maximum = 10
    }
  }

  # Fase 2: Networking + EKS Cluster + Managed Node Groups.
  proposal_mode = "EKS_CLUSTER"

  reviewed_execution = {
    # Nunca almacenar el Account ID real en GitHub.
    aws_account_id = var.aws_account_id

    # Segmento asignado por GP02 (orden ascendente, uno por workspace).
    networking = var.network

    # Laboratorio: ciclo crear/validar/destruir; sin esto el Destroy sería rechazado por EKS.
    deletion_protection = false
  }
}
