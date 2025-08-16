output "source_bucket_names" {
  description = "Names of all source S3 buckets"
  value = {
    for pair_key, pair in local.bucket_pairs : pair_key => local.get_bucket_reference[pair_key].source.id
  }
}

output "source_bucket_arns" {
  description = "ARNs of all source S3 buckets"
  value = {
    for pair_key, pair in local.bucket_pairs : pair_key => local.get_bucket_reference[pair_key].source.arn
  }
}

output "destination_bucket_names" {
  description = "Names of all destination S3 buckets"
  value = {
    for pair_key, pair in local.bucket_pairs : pair_key => local.get_bucket_reference[pair_key].destination.id
  }
}

output "destination_bucket_arns" {
  description = "ARNs of all destination S3 buckets"
  value = {
    for pair_key, pair in local.bucket_pairs : pair_key => local.get_bucket_reference[pair_key].destination.arn
  }
}

output "source_kms_key_arn" {
  description = "ARN of the source KMS key (used by all source buckets)"
  value       = local.source_kms_key_arn
}

output "destination_kms_key_arn" {
  description = "ARN of the destination KMS key (used by all destination buckets)"
  value       = local.destination_kms_key_arn
}

output "bucket_pairs" {
  description = "Mapping of bucket pairs for replication"
  value = {
    for pair_key, pair in local.bucket_pairs : pair_key => {
      source_bucket      = pair.source_name
      destination_bucket = pair.destination_name
      source_kms_arn     = local.source_kms_key_arn
      dest_kms_arn       = local.destination_kms_key_arn
    }
  }
}

output "environment" {
  description = "Current environment (nonprod or prod)"
  value       = var.env
}

output "resources_created" {
  description = "List of resources created by Terraform in this environment"
  value = {
    buckets_created = keys(local.buckets_to_create)
    kms_keys_created = keys(local.kms_keys_to_create)
  }
}

output "replication_role_arn" {
  description = "ARN of the S3 replication IAM role"
  value       = aws_iam_role.replication.arn
}

output "replication_configuration_ids" {
  description = "IDs of all S3 replication configurations"
  value = {
    for pair_key, config in aws_s3_bucket_replication_configuration.replication : pair_key => config.id
  }
}