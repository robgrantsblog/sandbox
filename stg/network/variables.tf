variable "cluster_name" {
  description = "Name of the EKS cluster used by the VPC and WAF configurations"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Domain name used for Route53 lookup and ACM certificate validation"
  type        = string
}