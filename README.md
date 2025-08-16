# S3 Same-Region Multi-Bucket Replication with Terraform

This Terraform configuration sets up S3 same-region replication for multiple bucket pairs with KMS encryption and environment-specific resource creation.

## Features

- **Multi-Bucket Support**: Replicate up to 4 buckets (or more) simultaneously
- **KMS Integration**: Use existing KMS key ARNs or create new keys automatically
- **Environment-Aware**: Different behavior for nonprod vs prod environments
- **DRY Principles**: Minimal code duplication using `for_each` and locals
- **Validation**: Built-in validation for configuration consistency

## Environment-Based Deployment

### NonProd Environment (`env = "nonprod"`)

- **Creates**: All source and destination S3 buckets
- **Creates**: KMS keys (only if ARNs not provided)
- **Configures**: Complete replication setup from scratch

### Prod Environment (`env = "prod"`)

- **Creates**: Only source S3 buckets
- **Uses**: Existing destination buckets (via data sources)
- **Creates**: KMS keys only if ARNs not provided
- **Configures**: Replication to existing destination resources

## Configuration

### Bucket Configuration

Provide lists of bucket names that must be the same length:

```hcl
source_bucket_names      = ["bucket-1", "bucket-2", "bucket-3", "bucket-4"]
destination_bucket_names = ["replica-1", "replica-2", "replica-3", "replica-4"]
```

### KMS Key Configuration

You can either:

1. **Provide existing KMS key ARNs** (recommended for prod):

```hcl
source_kms_key_arn = "arn:aws:kms:ap-southeast-2:123456789012:key/12345678-1234-1234-1234-123456789012"
destination_kms_key_arn = "arn:aws:kms:ap-southeast-2:123456789012:key/87654321-4321-4321-4321-210987654321"
```

2. **Leave as null to create new keys** (good for nonprod):

```hcl
source_kms_key_arn = null
destination_kms_key_arn = null
```

**Note**: One KMS key is used for all source buckets, and one KMS key is used for all destination buckets.

## Usage

### 1. NonProd Deployment (Create Everything)

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
env = "nonprod"
source_bucket_names = ["test-bucket-1", "test-bucket-2", "test-bucket-3", "test-bucket-4"]
destination_bucket_names = ["test-replica-1", "test-replica-2", "test-replica-3", "test-replica-4"]
# Leave KMS ARNs as null to create new keys
source_kms_key_arn = null
destination_kms_key_arn = null

# Deploy
terraform init
terraform plan
terraform apply
```

### 2. Prod Deployment (Use Existing Resources)

```bash
# Edit terraform.tfvars for prod
env = "prod"
source_bucket_names = ["prod-bucket-1", "prod-bucket-2", "prod-bucket-3", "prod-bucket-4"]
destination_bucket_names = ["prod-replica-1", "prod-replica-2", "prod-replica-3", "prod-replica-4"]
# Provide existing KMS key ARNs
source_kms_key_arns = ["arn:aws:kms:...", "arn:aws:kms:...", ...]
destination_kms_key_arns = ["arn:aws:kms:...", "arn:aws:kms:...", ...]

# Ensure destination buckets exist
# Deploy
terraform init
terraform plan
terraform apply
```

## File Structure

- `providers.tf` - AWS provider configuration
- `variables.tf` - Input variables with validation
- `locals.tf` - Local values and multi-bucket logic
- `main.tf` - S3 bucket resources
- `kms.tf` - KMS key resources (created only when needed)
- `iam.tf` - IAM role and policies for all buckets
- `replication.tf` - S3 replication configurations
- `outputs.tf` - Output values for all resources
- `validation.tf` - Configuration validation checks

## Variables

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `env` | Environment (nonprod/prod) | `string` | Yes |
| `source_bucket_names` | List of source bucket names | `list(string)` | Yes |
| `destination_bucket_names` | List of destination bucket names | `list(string)` | Yes |
| `source_kms_key_arn` | Source KMS key ARN (optional) | `string` | No |
| `destination_kms_key_arn` | Destination KMS key ARN (optional) | `string` | No |
| `aws_region` | AWS region | `string` | No |
| `replication_role_name` | IAM role name | `string` | No |

## Outputs

The configuration provides comprehensive outputs including:

- `bucket_pairs` - Complete mapping of all bucket pairs and their KMS keys
- `source_bucket_names` / `source_bucket_arns` - All source bucket details
- `destination_bucket_names` / `destination_bucket_arns` - All destination bucket details
- `source_kms_key_arn` / `destination_kms_key_arn` - KMS key ARNs for source and destination buckets
- `replication_configuration_ids` - All replication configuration IDs

## Validation

The configuration includes built-in validation to ensure:

- Source and destination bucket lists have the same length
- KMS key ARN lists (if provided) match the bucket list lengths
- All KMS ARNs follow the correct format

## Scaling

To add more buckets, simply extend the lists in your `terraform.tfvars`:

```hcl
source_bucket_names = ["bucket-1", "bucket-2", "bucket-3", "bucket-4", "bucket-5"]
destination_bucket_names = ["replica-1", "replica-2", "replica-3", "replica-4", "replica-5"]
```

The configuration will automatically create the additional replication pairs.
