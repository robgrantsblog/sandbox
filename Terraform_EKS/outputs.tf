output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "configure_kubectl" {
  description = "Command to update kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate for the domain"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  value       = data.aws_route53_zone.this.zone_id
}

output "lb_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller"
  value       = module.lb_controller_irsa_role.iam_role_arn
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by external-dns"
  value       = module.external_dns_irsa_role.iam_role_arn
}
