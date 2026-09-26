output "eks_secrets_key_arn" {
  description = "KMS key ARN used to encrypt Kubernetes secrets"
  value       = module.eks_secrets_kms.key_arn
}