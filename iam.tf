# IAM role for S3 same-region replication
resource "aws_iam_role" "replication" {
  name = var.replication_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "S3 Same-Region Replication Role"
  })
}

# Inline policy for the replication role with least privilege
resource "aws_iam_role_policy" "replication" {
  name = "s3-same-region-replication-policy"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetSourceBucketVersioning"
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.buckets["source"].arn
      },
      {
        Sid    = "GetSourceObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.buckets["source"].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption-aws-kms-key-id" = aws_kms_key.keys["source"].arn
          }
        }
      },
      {
        Sid    = "ReplicateToDestination"
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.buckets["destination"].arn}/*"
      },
      {
        Sid    = "DecryptSourceObjects"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.keys["source"].arn
      },
      {
        Sid    = "EncryptDestinationObjects"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*"
        ]
        Resource = aws_kms_key.keys["destination"].arn
      }
    ]
  })
}