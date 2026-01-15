source_aws_region = "us-east-1"
aws_profile       = "default"

backup_vault_name              = "main-backup-vault"
intermediate_backup_vault_name = "intermediate-backup-vault"
another_account_account_id     = "509633460021"

cmk_backup_vault = {
  enable_key_rotation = true
  description         = "KMS for Backup Vault Encryption"
  multi_region        = false
}

event_bridge_role = {
  name                 = "EventBridgeExecutionRole"
  path                 = "/"
  max_session_duration = 3600
}

backup_event_rule = null

lambda_function = null

lambda_function_env_variables = {
  LOG_LEVEL = "INFO"
}

lambda_archive_file = null

iam_role_lambda_backup_services = "LambdaBackupServiceRole"

copy_backup_destination_vault_name = {
  daily   = "arn:aws:backup:us-east-1:509633460021:backup-vault:daily-vault"
  weekly  = "arn:aws:backup:us-east-1:509633460021:backup-vault:weekly-vault"
}

backup_plan = {
  "DailyPlan" = {
    rules = {
      daily-rule = {
        rule_name                = "DailyRule"
        target_vault_name        = "main-backup-vault"
        schedule                 = "cron(0 5 * * ? *)"
        enable_continuous_backup = false
        start_window             = 60
        completion_window        = 120
        lifecycle = {
          cold_storage_after = 30
          delete_after       = 130   
        }
        recovery_point_tags = {
          type = "daily"
        }
        copy_action = {
          daily = {
            lifecycle = {
              cold_storage_after = 7
              delete_after       = 100 
            }
            destination_vault_arn = "arn:aws:backup:us-east-1:509633460021:backup-vault:daily-vault"
          }
        }
      }
    }
    
  }
}

backup_selection = {
  "DailySelection" = {
    plan_name = "DailyPlan"
    selection_tag = [
      {
        type  = "STRINGEQUALS"
        key   = "Backup"
        value = "true"
      }
    ]
    condition = []
    resources_arn     = ["arn:aws:ec2:us-east-1:509633460021:volume/*"]
    not_resources_arn = []
  }
}

iam_role = {
  name       = "BackupServiceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}


env = "dev"
owner = "opstree"
app = "otcloud-kit"
region = "us-east-1"
