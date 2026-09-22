# Terraform EKS

Provisions an AWS EKS cluster, links it to a Route53 domain over HTTPS, and
deploys a minimal example app to prove the whole chain works end to end.

## What this builds

- **VPC** ([vpc.tf](vpc.tf)) — 3 AZs, public + private subnets, single NAT gateway
- **EKS cluster** ([eks.tf](eks.tf)) — control plane and worker nodes in private
  subnets, managed node group, IRSA enabled, secrets encrypted with a
  dedicated KMS key ([kms.tf](kms.tf)), control-plane audit/API logs shipped
  to CloudWatch
- **Domain + TLS** ([route53.tf](route53.tf), [acm.tf](acm.tf)) — looks up
  your existing Route53 hosted zone and provisions a DNS-validated ACM
  certificate for the domain (plus `*.domain`)
- **Ingress plumbing** ([helm.tf](helm.tf), [irsa.tf](irsa.tf)) — installs the
  AWS Load Balancer Controller (creates an ALB from a Kubernetes `Ingress`)
  and external-dns (keeps the Route53 record pointed at that ALB
  automatically), each with a narrowly-scoped IAM role via IRSA
- **WAF** ([waf.tf](waf.tf)) — a regional Web ACL with AWS's Common Rule Set
  and Known Bad Inputs managed rules, attached to the ALB
- **Example app** ([example-app.tf](example-app.tf)) — a hardened nginx
  deployment (non-root, read-only root filesystem, dropped capabilities,
  resource limits) serving a static "Hello from EKS!" page, exposed at your
  domain over HTTPS
- **Remote state** ([bootstrap/](bootstrap/), backend block in
  [versions.tf](versions.tf)) — S3 backend with DynamoDB locking, created by a
  one-time bootstrap config

### Deliberate/accepted trade-offs

- `cluster_endpoint_public_access = true` — the EKS API server endpoint is
  reachable from the public internet (still requires valid IAM + RBAC to do
  anything). Kept public by choice; flip to `false` +
  `cluster_endpoint_private_access = true` in [eks.tf](eks.tf) if you want it
  VPC/VPN-only instead.
- `enable_cluster_creator_admin_permissions = true` — whoever runs
  `terraform apply` gets cluster-admin. Fine for solo use; add explicit
  `aws-auth` mappings if more people need access.

## Repo layout

```
Terraform_EKS/
├── versions.tf              # provider + backend requirements
├── providers.tf             # aws / kubernetes / helm provider config
├── variables.tf             # input variables (cluster_name, domain_name required)
├── terraform.tfvars         # your real values — gitignored
├── terraform.tfvars.example # placeholder template — committed
├── vpc.tf
├── eks.tf
├── kms.tf
├── irsa.tf
├── route53.tf
├── acm.tf
├── helm.tf
├── waf.tf
├── example-app.tf
├── outputs.tf
├── backend.hcl               # your real state-backend values — gitignored
├── backend.hcl.example       # placeholder template — committed
└── bootstrap/                 # one-time: creates the S3 bucket + DynamoDB table
    ├── main.tf
    ├── variables.tf
    ├── versions.tf
    ├── terraform.tfvars       # gitignored
    └── terraform.tfvars.example
```

Anything containing your real domain, cluster name, or state-backend names
is gitignored; only the `*.example` placeholder files are committed.

## Prerequisites

- Terraform >= 1.5
- AWS CLI, configured with credentials that can create VPC/EKS/IAM/ACM/Route53/WAF resources
- An existing Route53 public hosted zone for your domain
- The AWS CLI must remain installed at apply/plan time — the `kubernetes` and
  `helm` providers authenticate via `aws eks get-token` (see [providers.tf](providers.tf))

## Deploying

### 1. Bootstrap remote state (one-time)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # fill in a globally-unique bucket name + table name
terraform init
terraform apply
cd ..
```

### 2. Point the main config at that backend

```bash
cp backend.hcl.example backend.hcl   # same bucket/table names as step 1
terraform init -backend-config=backend.hcl
```

### 3. Set your cluster/domain values

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in cluster_name + domain_name
```

### 4. Deploy

```bash
terraform plan
terraform apply
```

This takes 15-20 minutes (EKS control plane creation is the slow part).

### 5. Verify

```bash
$(terraform output -raw configure_kubectl)   # aws eks update-kubeconfig ...
kubectl get pods -A
kubectl get ingress example-app
```

External-dns can take a few minutes after the ALB is provisioned to create
the Route53 record. Once it has, `https://<your-domain>` should serve
"Hello from EKS!".

## Tearing down

```bash
terraform destroy
```

The `bootstrap/` state bucket and lock table are left in place intentionally
(destroying your own state backend mid-destroy is a bad time). Destroy those
separately from `bootstrap/` only once you're fully done with this project.

## Cost

Rough estimate at defaults (2x `t3.medium`, single NAT gateway, us-east-1,
on-demand): **~$170/month**, excluding data transfer, WAF request charges,
and any additional load balancers you add. See the AWS Pricing Calculator
for a number specific to your account/region.

## Replacing the example app

[example-app.tf](example-app.tf) is a placeholder proving the
domain -> ALB -> cert -> pod chain works. Swap its `image`, ports, and
resource sizing for your real workload, or delete it and add your own
manifests — the ALB Controller, external-dns, ACM cert, and WAF are all
reusable by any `Ingress` you create afterward.
