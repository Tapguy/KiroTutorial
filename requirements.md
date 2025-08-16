# Requirements

## Functional Requirements

### S3 Same-Region Replication
- Create source S3 bucket `dg-outbound` in `ap-southeast-2`
- Create destination S3 bucket `dg-outbound-replica` in `ap-southeast-2`
- Configure same-region replication from source to destination
- Both buckets must have versioning enabled
- Replicate only objects encrypted with the source region KMS key

### Encryption Requirements
- Both buckets must use SSE-KMS encryption
- Each bucket must have its own distinct CMK (Customer Managed Key)
- Source objects encrypted with source bucket CMK
- Replicated objects encrypted with destination bucket CMK
- KMS keys must have key rotation enabled

### IAM Requirements
- Create dedicated IAM role for S3 replication service
- Implement least-privilege inline policy
- Role must have permissions to:
  - Read source bucket versioning configuration
  - Get source objects and their metadata (only KMS-encrypted objects)
  - Decrypt objects using source bucket KMS key
  - Replicate objects to destination bucket
  - Encrypt objects using destination bucket KMS key

### Infrastructure as Code
- Use Terraform for all infrastructure provisioning
- Leverage Terraform data blocks for AWS metadata (caller identity, partition)
- Organize code into logical files: providers.tf, main.tf, kms.tf, iam.tf, replication.tf, outputs.tf
- Use variables for configurable values with sane defaults
- Provide comprehensive outputs for key resource identifiers

## Non-Functional Requirements

### Security
- Follow AWS security best practices
- Implement least-privilege access controls
- Use customer-managed KMS keys for encryption
- Enable KMS key rotation

### Maintainability
- Code must be well-organized and documented
- Use consistent naming conventions
- Include comprehensive documentation
- Implement CI/CD validation

### Compliance
- All resources must be properly tagged
- Follow organizational naming standards
- Ensure audit trail for all operations

## Constraints

### Technical Constraints
- Must use Terraform as IaC tool
- Must use specified AWS region (ap-southeast-2)
- Must use specified bucket names (dg-outbound, dg-outbound-replica)
- Must implement same-region replication within single AWS account

### Operational Constraints
- Infrastructure must be deployable via automated CI/CD
- Must pass Terraform validation and formatting checks
- Must be compatible with Terraform >= 1.0
- Must use AWS Provider >= 5.0