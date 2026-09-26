output "web_acl_arn" {
  description = "ARN of the web ACL to attach to the application load balancer"
  value       = aws_wafv2_web_acl.example.arn
}