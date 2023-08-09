variable "aws_profile" {
  type = string
}

variable "another_account_account_id" {
  type = string

}

variable "backup_plan" {
  type = map(object({
    rules = map(object({
      rule_name                = string
      target_vault_name        = string
      schedule                 = optional(string)
      enable_continuous_backup = optional(bool)
      start_window             = optional(number)
      completion_window        = optional(number)

      lifecycle = optional(object({
        cold_storage_after = optional(number)
        delete_after       = optional(number)
      }))

      recovery_point_tags = optional(map(string))

      copy_action = optional(map(object({
        lifecycle = optional(object({
          cold_storage_after = optional(number)
          delete_after       = optional(number)
        }))
        destination_vault_arn = optional(string)
      })))
    }))

    advanced_backup_setting = optional(list(object({
      backup_options = map(string)
      resource_type  = string
    })))


    tags = optional(map(string))
  }))
  default = null
}

variable "copy_backup_destination_vault_name" {
  type    = map(string)
  default = null
}

variable "iam_role" {
  type = object({
    name       = string
    policy_arn = optional(string, "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup")
  })
  default = {
    name = "NewBackupPlanRole"
  }
}

variable "backup_selection" {
  type = map(object({
    plan_name = string
    selection_tag = optional(list(object({
      type  = optional(string, "STRINGEQUALS")
      key   = string
      value = string
    })))
    condition = optional(list(object({
      string_equals = optional(list(object({
        key   = string
        value = string
      })))
      string_like = optional(list(object({
        key   = string
        value = string
      })))
      string_not_equals = optional(list(object({
        key   = string
        value = string
      })))
      string_not_like = optional(list(object({
        key   = string
        value = string
      })))
    })))
    resources_arn     = optional(list(string))
    not_resources_arn = optional(list(string))
  }))
  default = null
}

variable "source_aws_region" {
  type    = string
  default = null
}

variable "cmk_backup_vault" {
  type = object({
    enable_key_rotation = bool
    description         = optional(string)
    multi_region        = bool
  })
  default = {
    enable_key_rotation = true
    description         = "KMS multi-region key for AWS Backup Vault"
    multi_region        = true
  }
}

variable "event_bridge_policy" {
  type = object({
    name = string
    path = string
  })
  default = {
    name = "AWSBackupCopyCompleteEventBridgePolicy"
    path = "/service-role/"
  }
}

variable "event_bridge_role" {
  type = object({
    name                 = string
    path                 = string
    max_session_duration = number
  })
  default = {
    name                 = "NewAWSBackupCopyCompleteEventBridgeRole"
    path                 = "/service-role/"
    max_session_duration = 3600
  }
}

variable "backup_event_rule" {
  type = object({
    name        = string
    description = string
  })
  default = null
}

variable "cloudwatch_event_target" {
  type = object({
    target_id      = string
    event_bus_name = string
  })
  default = {
    target_id      = "TargetVersion1"
    event_bus_name = "default"
  }
}

variable "iam_role_lambda_backup_services" {
  type = string
  default = "CopyBackupCrossAccount"
}

variable "backup_vault_name" {
  type        = string
  description = "The name of a logical container where source backups are stored."
  default     = "backup-vault"
}

variable "key_admin_identity" {
  type        = string
  description = "The principal element of the KMS key administrator."
  default     = "root"
}

variable "intermediate_aws_region" {
  type        = string
  description = "AWS Region for the cross-region backups to the Intermediate Vault."
  default     = null
}


# updating
variable "lambda_archive_file" {
  type = object({
    type        = string
    source_file = string
    output_path = string
  })
  default = null
}

variable "lambda_function" {
  type = object({
    name        = string
    description = optional(string)
    handler     = string
    runtime     = optional(string, "python3.10")
    memory_size = optional(number, 256)
    timeout     = optional(number, 300)
    filename    = string
  })
  default = null
}

variable "lambda_function_env_variables" {
  type    = map(string)
  default = null
}

variable "intermediate_lambda_function_name" {
  type    = string
  default = null
}

variable "intermediate_backup_vault_name" {
  type    = string
  default = null
}