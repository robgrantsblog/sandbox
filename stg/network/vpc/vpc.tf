module "vpc" {
  source = "git::ssh://git@github.com/robgrantsblog/sandbox_modules.git//modules/eks-vpc?ref=v1.0.0"

  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
}
