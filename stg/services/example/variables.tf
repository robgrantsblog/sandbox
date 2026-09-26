variable "aws_region" {
  description = "AWS region used by the AWS CLI EKS token provider"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster for AWS CLI authentication"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64-encoded EKS cluster certificate authority data"
  type        = string
}

variable "domain_name" {
  description = "Domain name served by the example application ingress"
  type        = string
}

variable "acm_certificate_arn" {
  description = "Validated ACM certificate ARN exported by the ACM stack"
  type        = string
}

variable "web_acl_arn" {
  description = "WAF web ACL ARN exported by the WAF stack"
  type        = string
}