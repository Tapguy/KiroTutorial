# S3 bucket replication configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [aws_s3_bucket_versioning.buckets]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.buckets["source"].id

  rule {
    id     = "ReplicateEncryptedObjects"
    status = "Enabled"

    # Only replicate objects encrypted with the source KMS key
    filter {
      prefix = ""
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    destination {
      bucket        = aws_s3_bucket.buckets["destination"].arn
      storage_class = "STANDARD"

      # Encrypt with destination KMS key
      encryption_configuration {
        replica_kms_key_id = aws_kms_key.keys["destination"].arn
      }

      # Replicate access control lists
      access_control_translation {
        owner = "Destination"
      }

      # Account ID for cross-account replication (same account in this case)
      account = data.aws_caller_identity.current.account_id
    }

    # Delete marker replication
    delete_marker_replication {
      status = "Enabled"
    }
  }
}