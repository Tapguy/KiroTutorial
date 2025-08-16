output "source_bucket_name" {
  description = "Name of the source S3 bucket"
  value       = aws_s3_bucket.buckets["source"].id
}

output "source_bucket_arn" {
  description = "ARN of the source S3 bucket"
  value       = aws_s3_bucket.buckets["source"].arn
}

output "destination_bucket_name" {
  description = "Name of the destination S3 bucket"
  value       = aws_s3_bucket.buckets["destination"].id
}

output "destination_bucket_arn" {
  description = "ARN of the destination S3 bucket"
  value       = aws_s3_bucket.buckets["destination"].arn
}

output "source_kms_key_id" {
  description = "ID of the source bucket KMS key"
  value       = aws_kms_key.keys["source"].key_id
}

output "source_kms_key_arn" {
  description = "ARN of the source bucket KMS key"
  value       = aws_kms_key.keys["source"].arn
}

output "destination_kms_key_id" {
  description = "ID of the destination bucket KMS key"
  value       = aws_kms_key.keys["destination"].key_id
}

output "destination_kms_key_arn" {
  description = "ARN of the destination bucket KMS key"
  value       = aws_kms_key.keys["destination"].arn
}

output "replication_role_arn" {
  description = "ARN of the S3 replication IAM role"
  value       = aws_iam_role.replication.arn
}

output "replication_configuration_id" {
  description = "ID of the S3 replication configuration"
  value       = aws_s3_bucket_replication_configuration.replication.id
}