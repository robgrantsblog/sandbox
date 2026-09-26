variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC created by the network VPC stack"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS cluster and node groups"
  type        = list(string)
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Trusted IPv4 CIDRs allowed to reach the public EKS API endpoint; set narrow ranges such as an office/VPN /32."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt Kubernetes secrets"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.36"
}
