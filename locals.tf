# Local values to reduce repetition and centralize common configurations
locals {
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Purpose     = "s3-replication"
    ManagedBy   = "terraform"
  }

  # Bucket configuration map for DRY bucket creation
  buckets = {
    source = {
      name         = var.source_bucket_name
      display_name = "Source Bucket"
    }
    destination = {
      name         = var.destination_bucket_name
      display_name = "Destination Bucket"
    }
  }

  # KMS key configuration map
  kms_keys = {
    source = {
      description = "KMS key for S3 encryption - source bucket"
      alias       = var.source_kms_key_alias
      display_name = "S3 Replication Source Key"
      actions     = ["kms:Decrypt", "kms:GenerateDataKey"]
    }
    destination = {
      description = "KMS key for S3 encryption - destination bucket"
      alias       = var.destination_kms_key_alias
      display_name = "S3 Replication Destination Key"
      actions     = ["kms:Encrypt", "kms:GenerateDataKey", "kms:ReEncrypt*"]
    }
  }

  # Common KMS policy statements
  kms_base_policy_statements = [
    {
      Sid    = "Enable IAM User Permissions"
      Effect = "Allow"
      Principal = {
        AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action   = "kms:*"
      Resource = "*"
    }
  ]
}