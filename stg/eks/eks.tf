module "eks" {
  source = "git::ssh://git@github.com/robgrantsblog/sandbox_modules.git//modules/eks-cluster?ref=v1.0.0"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  kms_key_arn        = var.kms_key_arn

  # This demo keeps the API endpoint public for operator access. Restrict it to
  # trusted IPv4 CIDRs in this stack's terraform.tfvars before applying.
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Demo convenience only; production callers should use explicit access_entries.
  enable_cluster_creator_admin_permissions = true
}
