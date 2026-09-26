# Terraform EKS

Provisions an AWS EKS cluster, links it to a Route53 domain over HTTPS, and
deploys a minimal example app to prove the whole chain works end to end.

## What this builds

- **VPC** ([network/vpc](network/vpc/)) — 3 AZs, public + private subnets, single NAT gateway
- **EKS cluster** ([eks](eks/)) — control plane and worker nodes in private
  subnets, managed node group, IRSA enabled, secrets encrypted with a
  dedicated KMS key ([kms](kms/)), control-plane audit/API logs shipped
  to CloudWatch
- **Domain + TLS** ([network/dns](network/dns/), [network/acm](network/acm/)) — looks up
  your existing Route53 hosted zone and provisions a DNS-validated ACM
  certificate for the domain (plus `*.domain`)
- **Ingress plumbing** ([lb](lb/), [iam](iam/)) — installs the
  AWS Load Balancer Controller (creates an ALB from a Kubernetes `Ingress`)
  and external-dns (keeps the Route53 record pointed at that ALB
  automatically), each with a narrowly-scoped IAM role via IRSA
- **WAF** ([network/waf](network/waf/)) — a regional Web ACL with AWS's Common Rule Set
  and Known Bad Inputs managed rules, attached to the ALB
- **Example app** ([services/example](services/example/)) — a hardened nginx
  deployment (non-root, read-only root filesystem, dropped capabilities,
  resource limits) serving a static "Hello from EKS!" page, exposed at your
  domain over HTTPS
- **Remote state** — each component stack uses an S3 backend with DynamoDB
  locking; the backend bucket and lock table are created once by
  [global/bootstrap_s3](../global/bootstrap_s3/).

### Deliberate/accepted trade-offs

- `cluster_endpoint_public_access = true` — the EKS API server endpoint is
  reachable from the public internet (still requires valid IAM + RBAC to do
  anything). Kept public by choice; flip to `false` +
  `cluster_endpoint_private_access = true` in [eks/eks.tf](eks/eks.tf) if you want it
  VPC/VPN-only instead.
- `enable_cluster_creator_admin_permissions = true` — whoever runs
  `terraform apply` gets cluster-admin. Fine for solo use; add explicit
  `aws-auth` mappings if more people need access.

## Repo layout

```
stg/
├── backend.hcl.example       # template; copy into each stack and set a unique key
├── eks/                      # EKS cluster
├── iam/                      # IRSA roles
├── kms/                      # EKS secrets encryption key
├── lb/                       # Helm releases for controllers
├── network/
│   ├── acm/  ├── dns/  ├── vpc/  └── waf/
└── services/example/         # example Kubernetes application
```

Each directory containing a Terraform stack has its own provider/backend
configuration and requires Terraform >= 1.10 for native S3 lockfiles. The
`stg/` root is not a Terraform stack, so it does not use a
root-level `terraform.tfvars`; keep one gitignored `terraform.tfvars` inside
each stack directory instead. Real `backend.hcl` and `terraform.tfvars` files
are gitignored; only example templates are committed. Use a different S3
`key` for every stack so their state objects do not overwrite one another.

## Prerequisites

- Terraform >= 1.10 (required for S3 native state locking with `use_lockfile`)
- AWS CLI, configured with credentials that can create VPC/EKS/IAM/ACM/Route53/WAF resources
- An existing Route53 public hosted zone for your domain
- The AWS CLI must remain installed at apply/plan time — the `kubernetes` and
  `helm` providers authenticate via `aws eks get-token` in their component stacks.

## Deploying

Start from the repository root (`sandbox/`).

### 1. Bootstrap remote state (one-time)

```bash
cd global/bootstrap_s3
cp terraform.tfvars.example terraform.tfvars   # fill in a globally-unique bucket name + table name
terraform init
terraform apply
cd ../../stg
```

### 2. Configure and initialize each component stack

```bash
cp -n backend.hcl.example eks/backend.hcl
# Edit eks/backend.hcl: use the bootstrap bucket and keep its key as eks/terraform.tfstate.
cd eks
terraform init -reconfigure -backend-config=backend.hcl
```

Repeat for `iam`, `kms`, `lb`, `network/acm`, `network/dns`, `network/vpc`,
`network/waf`, and `services/example`. Copy the template into each directory,
use the same bucket and set a unique `key` for every stack (for example,
`stg/network/vpc/terraform.tfstate`) before initializing it. The backend uses
S3's native `.tflock` objects; it no longer configures DynamoDB locking. The
bootstrap still provisions the old DynamoDB table for now; it is left in place
and can be retired separately after confirming nothing else uses it.

### 3. Set stack inputs and apply in dependency order

Create a gitignored `terraform.tfvars` in each stack directory, supplying the
required inputs listed in that directory's `variables.tf`. Pass outputs from
prerequisite stacks as inputs. Apply in this order: VPC and KMS, EKS, DNS and
WAF, ACM and IAM, load-balancer controllers, then the example service. Run from
each stack's own directory:

```bash
terraform plan
terraform apply
```

EKS control-plane creation is the slow step.

### 4. Verify

From the repository root:

```bash
cd stg/eks
$(terraform output -raw configure_kubectl)   # aws eks update-kubeconfig ...
kubectl get pods -A
kubectl get ingress example-app
```

External-dns can take a few minutes after the ALB is provisioned to create the
Route53 record. Once it has, `https://<your-domain>` should serve
"Hello from EKS!".

## Tearing down

Destroy component stacks individually, in reverse dependency order. Leave the
backend bucket in place until every stack has been retired. The legacy
DynamoDB lock table remains provisioned by the bootstrap and should only be
removed as a separate, deliberate cleanup.

## Cost

Rough estimate at defaults (2x `t3.medium`, single NAT gateway, us-east-1,
on-demand): **~$170/month**, excluding data transfer, WAF request charges,
and any additional load balancers you add. See the AWS Pricing Calculator
for a number specific to your account/region.

## Replacing the example app

[services/example/example-app.tf](services/example/example-app.tf) is a placeholder proving the
domain -> ALB -> cert -> pod chain works. Swap its `image`, ports, and
resource sizing for your real workload, or delete it and add your own
manifests — the ALB Controller, external-dns, ACM cert, and WAF are all
reusable by any `Ingress` you create afterward.
