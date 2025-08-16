# Design Document: S3 Same-Region Replication

## Architecture Overview

This solution implements same-region S3 replication within `ap-southeast-2` between two buckets with KMS encryption and least-privilege IAM controls.

## Component Design

### S3 Buckets

- **Source Bucket**: `dg-outbound` in `ap-southeast-2`
- **Destination Bucket**: `dg-outbound-replica` in `ap-southeast-2`
- Both buckets configured with:
  - Versioning enabled (required for replication)
  - SSE-KMS encryption with region-specific CMKs
  - S3 Bucket Key enabled for cost optimization

### KMS Keys

- **Source Key**: Customer-managed key for source bucket in `ap-southeast-2`
- **Destination Key**: Customer-managed key for destination bucket in `ap-southeast-2`
- Both keys configured with:
  - Automatic key rotation enabled
  - Key policies allowing IAM root access
  - Specific permissions for replication role
  - 7-day deletion window for safety

### IAM Role and Policy

- **Role**: `s3-same-region-replication-role`
- **Trust Policy**: Allows S3 service to assume the role
- **Permissions Policy**: Least-privilege inline policy with:
  - Source bucket versioning read access
  - Source object read access (KMS-encrypted objects only)
  - Destination bucket write access
  - KMS decrypt permissions for source key
  - KMS encrypt permissions for destination key

### Replication Configuration

- **Rule ID**: `ReplicateEncryptedObjects`
- **Filter**: All objects (empty prefix)
- **Source Selection**: Only SSE-KMS encrypted objects
- **Destination Encryption**: Re-encrypt with destination bucket KMS key
- **Delete Marker Replication**: Enabled
- **Access Control Translation**: Set destination bucket owner

## Security Design

### Encryption in Transit and at Rest

- All S3 objects encrypted at rest using SSE-KMS
- Distinct KMS keys per region prevent cross-region key dependencies
- TLS encryption for all API communications

### Access Control

- IAM role follows principle of least privilege
- Conditional access based on KMS key ID ensures only properly encrypted objects are replicated
- Same-region permissions carefully scoped to required actions only

### Key Management

- Distinct customer-managed keys per bucket provide granular control over encryption
- Automatic key rotation reduces long-term key exposure risk
- Key policies explicitly grant necessary permissions to replication role

## File Organization

```
├── providers.tf      # Terraform and AWS provider configuration
├── variables.tf      # Input variables with defaults
├── main.tf          # S3 buckets and basic configuration
├── kms.tf           # KMS keys and aliases
├── iam.tf           # IAM role and policies
├── replication.tf   # S3 replication configuration
├── outputs.tf       # Output values
├── requirements.md  # Functional and non-functional requirements
├── design.md        # This design document
├── tasks.md         # Implementation tasks
└── .github/
    └── workflows/
        └── terraform.yml # CI/CD pipeline
```

## Data Flow

1. Object uploaded to source bucket (`dg-outbound`)
2. S3 encrypts object using source region KMS key
3. Replication service assumes IAM role
4. Service reads object from source (if KMS-encrypted)
5. Service decrypts object using source KMS key
6. Service uploads object to destination bucket
7. S3 encrypts object using destination bucket KMS key
8. Replication completes with proper metadata preservation

## Monitoring and Observability

### CloudWatch Metrics

- S3 replication metrics automatically available
- KMS key usage metrics for both regions
- IAM role usage tracking

### Logging

- CloudTrail logs for all S3 and KMS API calls
- S3 access logs (if enabled separately)
- Replication failure notifications via S3 event notifications

## Disaster Recovery Considerations

- Same-region replication provides data redundancy within the region
- Independent KMS keys per bucket prevent single point of failure
- Versioning enables point-in-time recovery
- Delete marker replication maintains consistency

## Cost Optimization

- S3 Bucket Key enabled to reduce KMS API calls
- Standard storage class for replicated objects
- Automatic key rotation reduces operational overhead
- Least-privilege policies minimize unnecessary API calls
