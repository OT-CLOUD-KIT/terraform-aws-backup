locals {
  #  Policy for custom KMS key for backup vault
  cmk_backup_policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "backup-vault-cmk-policy-${var.backup_vault_name}",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow administration of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.key_admin_identity}"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion*",
          "kms:CancelKeyDeletion*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access from Backup account to copy backups",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "kms:CallerAccount" : "${var.another_account_account_id}"
          }
        }
      }
    ]
  })


  # Event bridge assume role
  event_bridge_assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  # Cloudwatch event for backup completed event pattern
  cloudwatch_event_pattern = jsonencode({
    "source" : ["aws.backup"],
    "detail-type" : ["Recovery Point State Change"],
    "detail" : {
      "status" : ["COMPLETED"],
      "backupVaultArn" : try(["arn:aws:backup:${var.source_aws_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.intermediate_backup_vault_name}"], ["arn:aws:backup:${var.source_aws_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.backup_vault_name}"])
    }
  })
}