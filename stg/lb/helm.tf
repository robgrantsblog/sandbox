module "eks_addons" {
  source = "git::ssh://git@github.com/robgrantsblog/sandbox_modules.git//modules/eks-addons?ref=v1.0.0"

  cluster_name           = var.cluster_name
  aws_region             = var.aws_region
  vpc_id                 = var.vpc_id
  domain_name            = var.domain_name
  lb_controller_role_arn = var.lb_controller_role_arn
  external_dns_role_arn  = var.external_dns_role_arn

  aws_load_balancer_controller_chart_version = var.aws_load_balancer_controller_chart_version
  external_dns_chart_version                 = var.external_dns_chart_version
}
