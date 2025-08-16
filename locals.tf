# Local values to reduce repetition and centralize common configurations
locals {
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Purpose     = "s3-replication"
    ManagedBy   = "terraform"
  }

  # Environment-based resource creation flags
  is_nonprod = var.env == "nonprod"
  is_prod    = var.env == "prod"

  # Validation checks
  bucket_count_match = length(var.source_bucket_names) == length(var.destination_bucket_names)

  # Validation errors
  validation_errors = compact([
    !local.bucket_count_match ? "source_bucket_names and destination_bucket_names must have the same length" : null
  ])

  # Create bucket pairs mapping
  bucket_pairs = {
    for i in range(length(var.source_bucket_names)) : "pair-${i}" => {
      source_name      = var.source_bucket_names[i]
      destination_name = var.destination_bucket_names[i]
    }
  }

  # Source buckets to create (always create)
  source_buckets_to_create = {
    for pair_key, pair in local.bucket_pairs : "${pair_key}-source" => {
      name         = pair.source_name
      display_name = "Source Bucket ${pair.source_name}"
      pair_key     = pair_key
    }
  }

  # Destination buckets to create (only in nonprod)
  destination_buckets_to_create = var.env == "nonprod" ? {
    for pair_key, pair in local.bucket_pairs : "${pair_key}-destination" => {
      name         = pair.destination_name
      display_name = "Destination Bucket ${pair.destination_name}"
      pair_key     = pair_key
    }
  } : {}

  # All buckets to create
  buckets_to_create = merge(local.source_buckets_to_create, local.destination_buckets_to_create)

  # All buckets (for data source references in prod)
  all_buckets = merge(
    {
      for pair_key, pair in local.bucket_pairs : "${pair_key}-source" => {
        name         = pair.source_name
        display_name = "Source Bucket ${pair.source_name}"
        pair_key     = pair_key
      }
    },
    {
      for pair_key, pair in local.bucket_pairs : "${pair_key}-destination" => {
        name         = pair.destination_name
        display_name = "Destination Bucket ${pair.destination_name}"
        pair_key     = pair_key
      }
    }
  )

  # KMS keys to create (only when ARNs are not provided)
  kms_keys_to_create = merge(
    var.source_kms_key_arn == null ? {
      source = {
        description  = "KMS key for S3 encryption - all source buckets"
        display_name = "S3 Replication Source Key"
        actions      = ["kms:Decrypt", "kms:GenerateDataKey"]
      }
    } : {},
    var.env == "nonprod" && var.destination_kms_key_arn == null ? {
      destination = {
        description  = "KMS key for S3 encryption - all destination buckets"
        display_name = "S3 Replication Destination Key"
        actions      = ["kms:Encrypt", "kms:GenerateDataKey", "kms:ReEncrypt*"]
      }
    } : {}
  )



  # Helper function to get bucket reference
  get_bucket_reference = {
    for pair_key, pair in local.bucket_pairs : pair_key => {
      source = local.is_nonprod ? aws_s3_bucket.buckets["${pair_key}-source"] : data.aws_s3_bucket.existing_buckets["${pair_key}-source"]
      destination = local.is_nonprod ? aws_s3_bucket.buckets["${pair_key}-destination"] : data.aws_s3_bucket.existing_buckets["${pair_key}-destination"]
    }
  }

  # KMS key references (single key for all source buckets, single key for all destination buckets)
  source_kms_key_arn = var.source_kms_key_arn != null ? var.source_kms_key_arn : aws_kms_key.keys["source"].arn
  destination_kms_key_arn = var.destination_kms_key_arn != null ? var.destination_kms_key_arn : (
    local.is_nonprod ? aws_kms_key.keys["destination"].arn : var.destination_kms_key_arn
  )
}