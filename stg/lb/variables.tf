variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domain name used to configure external-dns filters"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster API endpoint used by the Helm provider"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64-encoded EKS cluster certificate authority data"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID exported by the network VPC stack"
  type        = string
}

variable "lb_controller_role_arn" {
  description = "IAM role ARN exported by the IRSA stack for the load balancer controller"
  type        = string
}

variable "external_dns_role_arn" {
  description = "IAM role ARN exported by the IRSA stack for external-dns"
  type        = string
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Pinned AWS Load Balancer Controller Helm chart version"
  type        = string
}

variable "external_dns_chart_version" {
  description = "Pinned external-dns Helm chart version"
  type        = string
}
