module "waf" {
  source = "git::ssh://git@github.com/robgrantsblog/sandbox_modules.git//modules/alb-waf?ref=v1.0.0"

  name        = "${var.cluster_name}-example-app"
  description = "Baseline AWS managed-rule protection for the example app's ALB"
}
