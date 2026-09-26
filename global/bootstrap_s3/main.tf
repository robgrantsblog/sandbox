# One-time bootstrap: creates the S3 state bucket and a legacy DynamoDB lock
# table. New staging stacks use S3 native lockfiles; the table is retained for
# compatibility until it is deliberately retired.
# This config's own state stays local — run it once, then never again
# unless you're changing the backend itself.
#
# Usage:
#   cd global/bootstrap_s3
#   cp terraform.tfvars.example terraform.tfvars   # fill in your own values
#   terraform init && terraform apply
#   cd ../../stg/<stack> and initialize with that stack's backend.hcl

resource "aws_s3_bucket" "tfstate" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
