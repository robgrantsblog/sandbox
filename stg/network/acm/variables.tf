variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domain name for the ACM certificate and wildcard certificate"
  type        = string
}

variable "route53_zone_id" {
  description = "Public Route53 hosted-zone ID exported by the DNS stack"
  type        = string
}