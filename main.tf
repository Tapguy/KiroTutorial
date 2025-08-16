# Data sources for existing buckets in prod environment
data "aws_s3_bucket" "existing_buckets" {
  for_each = local.is_prod ? local.all_buckets : {}
  bucket   = each.value.name
}

# S3 buckets - create only in nonprod or source bucket in prod
resource "aws_s3_bucket" "buckets" {
  for_each = local.buckets_to_create
  
  bucket = each.value.name
  tags = merge(local.common_tags, {
    Name = each.value.display_name
  })
}

# Bucket versioning configuration - only for created buckets
resource "aws_s3_bucket_versioning" "buckets" {
  for_each = aws_s3_bucket.buckets
  
  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket server-side encryption configuration - only for created buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "buckets" {
  for_each = aws_s3_bucket.buckets
  
  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = strcontains(each.key, "source") ? local.source_kms_key_arn : local.destination_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}