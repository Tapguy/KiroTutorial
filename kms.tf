# KMS keys using for_each to reduce repetition
resource "aws_kms_key" "keys" {
  for_each = local.kms_keys
  
  description             = each.value.description
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = var.enable_kms_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      local.kms_base_policy_statements,
      [
        {
          Sid    = "Allow S3 replication role"
          Effect = "Allow"
          Principal = {
            AWS = aws_iam_role.replication.arn
          }
          Action   = each.value.actions
          Resource = "*"
        }
      ]
    )
  })

  tags = merge(local.common_tags, {
    Name = each.value.display_name
  })
}

# KMS aliases
resource "aws_kms_alias" "keys" {
  for_each = local.kms_keys
  
  name          = each.value.alias
  target_key_id = aws_kms_key.keys[each.key].key_id
}

