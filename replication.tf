# S3 bucket replication configurations - one per source bucket
resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each = local.bucket_pairs
  
  depends_on = [aws_s3_bucket_versioning.buckets]

  role   = aws_iam_role.replication.arn
  bucket = local.get_bucket_reference[each.key].source.id

  rule {
    id     = "ReplicateEncryptedObjects-${each.key}"
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
      bucket        = local.get_bucket_reference[each.key].destination.arn
      storage_class = "STANDARD"

      # Encrypt with destination KMS key
      encryption_configuration {
        replica_kms_key_id = local.destination_kms_key_arn
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