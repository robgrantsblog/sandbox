output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate for the domain"
  value       = aws_acm_certificate_validation.this.certificate_arn
}
