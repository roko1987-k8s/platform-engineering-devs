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

  team_id            = "D002"
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

  proposal_mode = "DESIGN_WITHOUT_AWS_ACCOUNT"
}
