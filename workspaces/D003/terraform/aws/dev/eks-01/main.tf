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

  team_id            = "D003"
  application_code   = "adp-eks"
  environment        = "dev"
  region             = "us-east-1"
  sequence           = 1
  kubernetes_version = "1.36"

  system_size = "S"
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
      maximum = 2
    }
  }

  # Fase 2: Networking + EKS Cluster + Managed Node Groups.
  proposal_mode = "EKS_CLUSTER"

  reviewed_execution = {
    # Nunca almacenar el Account ID real en GitHub.
    aws_account_id = var.aws_account_id

    # Networking: completar en un PR revisado con los CIDR aprobados
    # (vpc_cidr, cluster/node/public subnet CIDRs y approval_reference).
    # Mientras sea null, el Plan se detiene en GATE_NETWORKING_PENDING.
    networking = null

    # Laboratorio: ciclo crear/validar/destruir; sin esto el Destroy sería rechazado por EKS.
    deletion_protection = false
  }
}
