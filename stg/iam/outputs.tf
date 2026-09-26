output "lb_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller"
  value       = module.eks_irsa.lb_controller_role_arn
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by external-dns"
  value       = module.eks_irsa.external_dns_role_arn
}