# sandbox
This is where I test various things.

## Terraform_EKS

Terraform config that provisions an AWS EKS cluster, links it to a Route53
domain over HTTPS (ALB + ACM + external-dns), and includes some baseline
security hardening (KMS-encrypted secrets, control plane logging, WAF, IRSA,
hardened pod security context). See [Terraform_EKS/README.md](Terraform_EKS/README.md)
for details and deployment steps.

This is for demonstration purposes only — not intended to be deployed as-is
for a real production workload.
