output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate for the domain"
  value       = module.acm_certificate.certificate_arn
}
