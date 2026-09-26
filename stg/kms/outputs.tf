output "eks_secrets_key_arn" {
  description = "KMS key ARN used to encrypt Kubernetes secrets"
  value       = aws_kms_key.eks_secrets.arn
}