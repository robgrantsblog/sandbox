output "route53_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  value       = module.route53_zone.zone_id
}

output "route53_zone_arn" {
  description = "Public Route53 hosted-zone ARN used to scope external-dns access"
  value       = module.route53_zone.zone_arn
}
