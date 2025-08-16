# IAM assume role policy document for S3 replication
data "aws_iam_policy_document" "replication_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

# IAM policy document for S3 replication permissions
data "aws_iam_policy_document" "replication_policy" {
  # Allow getting bucket versioning configuration
  statement {
    sid    = "GetSourceBucketsVersioning"
    effect = "Allow"
    
    actions = [
      "s3:GetBucketVersioning"
    ]
    
    resources = [
      for pair_key, pair in local.bucket_pairs : local.get_bucket_reference[pair_key].source.arn
    ]
  }

  # Allow getting source objects for replication
  statement {
    sid    = "GetSourceObjects"
    effect = "Allow"
    
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    
    resources = [
      for pair_key, pair in local.bucket_pairs : "${local.get_bucket_reference[pair_key].source.arn}/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [local.source_kms_key_arn]
    }
  }

  # Allow replicating to destination buckets
  statement {
    sid    = "ReplicateToDestinations"
    effect = "Allow"
    
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    
    resources = [
      for pair_key, pair in local.bucket_pairs : "${local.get_bucket_reference[pair_key].destination.arn}/*"
    ]
  }

  # Allow decrypting source objects
  statement {
    sid    = "DecryptSourceObjects"
    effect = "Allow"
    
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    
    resources = [local.source_kms_key_arn]
  }

  # Allow encrypting destination objects
  statement {
    sid    = "EncryptDestinationObjects"
    effect = "Allow"
    
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*"
    ]
    
    resources = [local.destination_kms_key_arn]
  }
}

# IAM role for S3 same-region replication
resource "aws_iam_role" "replication" {
  name               = var.replication_role_name
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role.json

  tags = merge(local.common_tags, {
    Name = "S3 Same-Region Replication Role"
  })
}

# Inline policy for the replication role with least privilege
resource "aws_iam_role_policy" "replication" {
  name   = "s3-same-region-replication-policy"
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication_policy.json
}