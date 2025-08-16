variable "aws_region" {
  description = "AWS region for both S3 buckets (same-region replication)"
  type        = string
  default     = "ap-southeast-2"
}

variable "source_bucket_name" {
  description = "Name of the source S3 bucket"
  type        = string
  default     = "dg-outbound"
}

variable "destination_bucket_name" {
  description = "Name of the destination S3 bucket"
  type        = string
  default     = "dg-outbound-replica"
}

variable "source_kms_key_alias" {
  description = "Alias for the source bucket KMS key"
  type        = string
  default     = "alias/s3-replication-source"
}

variable "destination_kms_key_alias" {
  description = "Alias for the destination bucket KMS key"
  type        = string
  default     = "alias/s3-replication-destination"
}

variable "replication_role_name" {
  description = "Name for the S3 replication IAM role"
  type        = string
  default     = "s3-same-region-replication-role"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "production"
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
}

variable "enable_kms_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}