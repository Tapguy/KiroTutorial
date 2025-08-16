variable "aws_region" {
  description = "AWS region for both S3 buckets (same-region replication)"
  type        = string
  default     = "ap-southeast-2"
}

variable "source_bucket_names" {
  description = "List of source S3 bucket names"
  type        = list(string)
  default     = ["dg-outbound-1", "dg-outbound-2", "dg-outbound-3", "dg-outbound-4"]
  
  validation {
    condition     = length(var.source_bucket_names) > 0
    error_message = "At least one source bucket name must be provided."
  }
}

variable "destination_bucket_names" {
  description = "List of destination S3 bucket names (must match length of source_bucket_names)"
  type        = list(string)
  default     = ["dg-outbound-replica-1", "dg-outbound-replica-2", "dg-outbound-replica-3", "dg-outbound-replica-4"]
  
  validation {
    condition     = length(var.destination_bucket_names) > 0
    error_message = "At least one destination bucket name must be provided."
  }
}

variable "source_kms_key_arn" {
  description = "Source KMS key ARN (used by all source buckets). If not provided, a key will be created."
  type        = string
  default     = null
  
  validation {
    condition = var.source_kms_key_arn == null || can(regex("^arn:aws:kms:", var.source_kms_key_arn))
    error_message = "Source KMS key ARN must be a valid AWS KMS ARN starting with 'arn:aws:kms:' or null."
  }
}

variable "destination_kms_key_arn" {
  description = "Destination KMS key ARN (used by all destination buckets). If not provided, a key will be created."
  type        = string
  default     = null
  
  validation {
    condition = var.destination_kms_key_arn == null || can(regex("^arn:aws:kms:", var.destination_kms_key_arn))
    error_message = "Destination KMS key ARN must be a valid AWS KMS ARN starting with 'arn:aws:kms:' or null."
  }
}

variable "replication_role_name" {
  description = "Name for the S3 replication IAM role"
  type        = string
  default     = "s3-same-region-replication-role"
}

variable "env" {
  description = "Environment (nonprod or prod) - determines resource creation behavior"
  type        = string
  default     = "nonprod"
  
  validation {
    condition     = contains(["nonprod", "prod"], var.env)
    error_message = "Environment must be either 'nonprod' or 'prod'."
  }
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