resource "aws_kms_key" "eks_secrets" {
  description             = "Envelope encryption key for ${var.cluster_name} Kubernetes secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}
