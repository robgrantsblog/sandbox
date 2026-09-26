output "web_acl_arn" {
  description = "ARN of the web ACL to attach to the application load balancer"
  value       = module.waf.web_acl_arn
}