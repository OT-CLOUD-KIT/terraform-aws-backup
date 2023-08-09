provider "aws" {
  region  = var.source_aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "backup_vault" {
  enable_key_rotation = var.cmk_backup_vault.enable_key_rotation
  description         = var.cmk_backup_vault.description
  multi_region        = var.cmk_backup_vault.multi_region
  policy              = local.cmk_backup_policy
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/cmk-${var.backup_vault_name}"
  target_key_id = aws_kms_key.backup_vault.key_id
}

resource "aws_backup_vault" "backup_vault" {
  name        = var.backup_vault_name
  kms_key_arn = aws_kms_key.backup_vault.arn
}

data "aws_iam_policy_document" "copy_backup" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.another_account_account_id}:root"]
    }

    actions = ["backup:CopyIntoBackupVault"]

    resources = ["*"]
  }
}

resource "aws_backup_vault_policy" "assign" {
  backup_vault_name = aws_backup_vault.backup_vault.name
  policy            = data.aws_iam_policy_document.copy_backup.json
}

resource "aws_backup_vault" "intermediate_backup_vault" {
  count       = var.intermediate_backup_vault_name != null ? 1 : 0
  name        = var.intermediate_backup_vault_name
  kms_key_arn = aws_kms_key.backup_vault.arn
}

resource "aws_iam_role" "event_bridge_role" {
  count                = var.backup_event_rule != null ? 1 : 0
  name                 = var.event_bridge_role.name
  path                 = var.event_bridge_role.path
  assume_role_policy   = local.event_bridge_assume_role_policy
  max_session_duration = var.event_bridge_role.max_session_duration
}

resource "aws_cloudwatch_event_rule" "aws_backup_completed_rule" {
  count         = var.backup_event_rule != null ? 1 : 0
  name          = var.backup_event_rule.name
  description   = var.backup_event_rule.description
  event_pattern = local.cloudwatch_event_pattern
}

data "archive_file" "lambda" {
  count       = var.lambda_function != null ? 1 : 0
  type        = var.lambda_archive_file.type
  source_file = var.lambda_archive_file.source_file
  output_path = var.lambda_archive_file.output_path
}

resource "aws_lambda_function" "invoke_lambda" {
  count            = var.lambda_function != null ? 1 : 0
  function_name    = var.lambda_function.name
  description      = var.lambda_function.description
  handler          = var.lambda_function.handler
  runtime          = var.lambda_function.runtime
  memory_size      = var.lambda_function.memory_size
  timeout          = var.lambda_function.timeout
  role             = aws_iam_role.backup_copy_manager_role[0].arn
  filename         = var.lambda_function.filename
  source_code_hash = data.archive_file.lambda[0].output_base64sha256
  environment {
    variables = var.lambda_function_env_variables
  }
}

resource "aws_iam_role" "backup_copy_manager_role" {
  count = var.lambda_function != null ? 1 : 0
  name  = var.iam_role_lambda_backup_services
  path  = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "backup.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "backup_copy_manager_lambda_cloudwatch_policy" {
  count      = var.lambda_function != null ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_copy_manager_role[0].name
}

data "aws_iam_policy_document" "lambda_cloudwatch_policy" {
  count = var.lambda_function != null ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  count       = var.lambda_function != null ? 1 : 0
  name        = "BackupCopyManagerLambdaCloudwatchPolicy"
  description = "Backup copy manager lambda cloudwatch policy"
  policy      = data.aws_iam_policy_document.lambda_cloudwatch_policy[0].json
}

resource "aws_iam_role_policy_attachment" "backup_copy_manager_lambda_pass_role_policy" {
  count      = var.lambda_function != null ? 1 : 0
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy[0].arn
  role       = aws_iam_role.backup_copy_manager_role[0].name
}

data "aws_iam_policy_document" "backup_copy_manager_lambda_backup_permissions_policy" {
  count = var.lambda_function != null ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "backup:StartCopyJob",
      "backup:ListTags",
      "backup:DescribeRecoveryPoint"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "backup_copy_manager_lambda_backup_permissions_policy" {
  count       = var.lambda_function != null ? 1 : 0
  name        = "BackupCopyManagerLambdaBackupPermissionsPolicy"
  description = "Backup copy manager lambda backup permissions policy"
  policy      = data.aws_iam_policy_document.backup_copy_manager_lambda_backup_permissions_policy[0].json
}

resource "aws_iam_role_policy_attachment" "backup_copy_manager_lambda_backup_permissions_policy" {
  count      = var.lambda_function != null ? 1 : 0
  policy_arn = aws_iam_policy.backup_copy_manager_lambda_backup_permissions_policy[0].arn
  role       = aws_iam_role.backup_copy_manager_role[0].name
}

data "aws_iam_policy_document" "iam_passrole" {
   count      = var.lambda_function != null ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_role_lambda_backup_services}"
    ]
  }
}

resource "aws_iam_policy" "iam_passrole_policy" {
   count      = var.lambda_function != null ? 1 : 0
  name        = "LambdaPassRole"
  description = "For Lambda pass role to AWS backup service"
  policy      = data.aws_iam_policy_document.iam_passrole[0].json
}

resource "aws_iam_role_policy_attachment" "passrole_policy_attachment" {
   count      = var.lambda_function != null ? 1 : 0
  policy_arn = aws_iam_policy.iam_passrole_policy[0].arn
  role       = aws_iam_role.backup_copy_manager_role[0].name
}

resource "aws_lambda_permission" "process_copy_job_status_event_rule_invoke_permission" {
  count         = var.lambda_function != null ? 1 : 0
  statement_id  = "NewAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invoke_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aws_backup_completed_rule[0].arn
}

resource "aws_cloudwatch_event_target" "process_copy_job_status_event_rule_lambda_target" {
  count     = var.backup_event_rule != null ? 1 : 0
  rule      = aws_cloudwatch_event_rule.aws_backup_completed_rule[0].name
  target_id = "InvokeCrossRegionLambda"
  arn       = aws_lambda_function.invoke_lambda[0].arn
}

resource "aws_backup_plan" "backup" {
  for_each = var.backup_plan != null ? var.backup_plan : {}
  name     = each.key
  dynamic "rule" {
    for_each = each.value.rules
    content {
      rule_name                = rule.value.rule_name
      target_vault_name        = rule.value.target_vault_name
      schedule                 = rule.value.schedule
      enable_continuous_backup = rule.value.enable_continuous_backup
      start_window             = rule.value.start_window
      completion_window        = rule.value.completion_window

      lifecycle {
        cold_storage_after = rule.value.lifecycle.cold_storage_after
        delete_after       = rule.value.lifecycle.delete_after

      }
      recovery_point_tags = rule.value.recovery_point_tags
      dynamic "copy_action" {
        for_each = rule.value.copy_action != null ? rule.value.copy_action : {}
        content {
          lifecycle {
            cold_storage_after = copy_action.value.lifecycle.cold_storage_after
            delete_after       = copy_action.value.lifecycle.delete_after
          }
          destination_vault_arn = copy_action.value.destination_vault_arn != null ? copy_action.value.destination_vault_arn : var.copy_backup_destination_vault_name[copy_action.key]
        }
      }
    }
  }
  dynamic "advanced_backup_setting" {
    for_each = each.value.advanced_backup_setting != null ? each.value.advanced_backup_setting : []
    content {
      backup_options = advanced_backup_setting.value.backup_options
      resource_type  = advanced_backup_setting.value.resource_type
    }
  }
  tags       = each.value.tags
  depends_on = [aws_backup_vault.backup_vault]
}

data "aws_iam_policy_document" "assume_role" {
  count = var.backup_selection != null ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup_plan" {
  count              = var.backup_selection != null ? 1 : 0
  name               = var.iam_role.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.0.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  count      = var.backup_selection != null ? 1 : 0
  policy_arn = var.iam_role.policy_arn
  role       = aws_iam_role.backup_plan.0.name
}

resource "aws_backup_selection" "service" {
  for_each     = var.backup_selection != null ? var.backup_selection : {}
  iam_role_arn = aws_iam_role.backup_plan.0.arn
  name         = each.key
  plan_id      = aws_backup_plan.backup[each.value.plan_name].id
  dynamic "selection_tag" {
    for_each = each.value.selection_tag != null ? each.value.selection_tag : []
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }
  dynamic "condition" {
    for_each = each.value.condition != null ? each.value.condition : []
    content {
      dynamic "string_equals" {
        for_each = condition.value.string_equals != null ? condition.value.string_equals : []
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }
      dynamic "string_like" {
        for_each = condition.value.string_like != null ? condition.value.string_like : []
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }
      dynamic "string_not_equals" {
        for_each = condition.value.string_not_equals != null ? condition.value.string_not_equals : []
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }
      dynamic "string_not_like" {
        for_each = condition.value.string_not_like != null ? condition.value.string_not_like : []
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }
  resources     = each.value.resources_arn
  not_resources = each.value.not_resources_arn
  depends_on    = [aws_backup_plan.backup]
}
