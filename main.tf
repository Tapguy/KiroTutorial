# S3 buckets using for_each to reduce repetition
resource "aws_s3_bucket" "buckets" {
  for_each = local.buckets
  
  bucket = each.value.name
  tags = merge(local.common_tags, {
    Name = each.value.display_name
  })
}

# Bucket versioning configuration
resource "aws_s3_bucket_versioning" "buckets" {
  for_each = aws_s3_bucket.buckets
  
  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "buckets" {
  for_each = aws_s3_bucket.buckets
  
  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.keys[each.key].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}