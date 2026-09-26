module "acm_certificate" {
  source = "git::ssh://git@github.com/robgrantsblog/sandbox_modules.git//modules/acm-dns-certificate?ref=v1.0.0"

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  route53_zone_id           = var.route53_zone_id
}
