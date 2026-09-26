# sandbox

A collection of infrastructure experiments and demos.

## Current projects

### Shared Terraform state bootstrap

[global/bootstrap_s3](global/bootstrap_s3/) contains a one-time AWS bootstrap
configuration for the shared Terraform state S3 bucket and a legacy DynamoDB
lock table. Staging stacks use S3 native lockfiles (`use_lockfile = true`); the
table is retained for compatibility and is not currently used by those stacks.
The bucket has versioning, SSE-KMS encryption, public-access blocking, and
Terraform `prevent_destroy` protection. The bootstrap's own state uses
Terraform's local backend.

### Staging EKS demo

[stg](stg/) provisions a demonstration EKS environment, divided into standalone
Terraform stacks for VPC, DNS, ACM, WAF, KMS, EKS, IRSA roles, Helm controllers,
and an example Kubernetes service. Each stack has its own remote-state key and
its own ignored `terraform.tfvars`; values from prerequisite stacks are passed
to dependent stacks as inputs.

See [stg/README.md](stg/README.md) for prerequisites, backend setup, stack order,
and deployment instructions.

This is a learning/demo configuration, not a production-ready deployment. The
EKS API endpoint is public by default, cluster creator permissions are
administrative, and AWS resources can incur ongoing costs. Review the staging
README and Terraform plans before applying.
