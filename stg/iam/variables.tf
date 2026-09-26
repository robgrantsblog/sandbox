variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster used to name IAM roles"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "OIDC provider ARN exported by the EKS stack"
  type        = string
}

variable "route53_zone_arn" {
  description = "Public Route53 hosted-zone ARN used to scope external-dns access"
  type        = string
}