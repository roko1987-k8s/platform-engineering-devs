terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.20.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "git::https://github.com/roko1987-k8s/platform-engineering-modules-tfc.git//aws/dev/eks?ref=main"

  team_id            = "P001"
  application_code   = "adp-eks"
  environment        = "dev"
  region             = "us-east-1"
  sequence           = 1
  kubernetes_version = "1.36"

  system_size = "S"
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

  proposal_mode = "DESIGN_WITHOUT_AWS_ACCOUNT"
}
