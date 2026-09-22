terraform {
  required_version = ">= 1.5.0"

  # Backend values live in backend.hcl (gitignored — see backend.hcl.example),
  # not here, so the bucket/table names aren't published in the repo.
  # One-time setup: apply Terraform_EKS/bootstrap/ first to create them, then run
  #   terraform init -backend-config=backend.hcl
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}
