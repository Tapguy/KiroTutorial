# KMS key policy document
data "aws_iam_policy_document" "kms_key_policy" {
  for_each = local.kms_keys_to_create

  # Enable IAM User Permissions
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow S3 replication role
  statement {
    sid    = "Allow S3 replication role"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication.arn]
    }
    
    actions   = each.value.actions
    resources = ["*"]
  }
}

# KMS keys - create only when ARNs are not provided
resource "aws_kms_key" "keys" {
  for_each = local.kms_keys_to_create
  
  description             = each.value.description
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = var.enable_kms_rotation
  policy                  = data.aws_iam_policy_document.kms_key_policy[each.key].json

  tags = merge(local.common_tags, {
    Name = each.value.display_name
  })
}

