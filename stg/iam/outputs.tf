output "lb_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller"
  value       = module.lb_controller_irsa_role.iam_role_arn
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by external-dns"
  value       = module.external_dns_irsa_role.iam_role_arn
}