variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name for Terraform remote state"
  type        = string
}

variable "lock_table_name" {
  description = "Legacy DynamoDB lock table name, retained for existing clients"
  type        = string
}
