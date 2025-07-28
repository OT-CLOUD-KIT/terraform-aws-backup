variable "source_aws_region" {
  description = "AWS region where the resources will be created."
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile name to use for credentials."
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the AWS Backup Vault."
  type        = string
}

variable "intermediate_backup_vault_name" {
  description = "Optional intermediate backup vault name."
  type        = string
  default     = null
}

variable "another_account_account_id" {
  description = "AWS Account ID of the other account that needs backup copy permission."
  type        = string
}

variable "cmk_backup_vault" {
  description = "KMS configuration for backup vault."
  type = object({
    enable_key_rotation = bool
    description         = string
    multi_region        = bool
  })
}

variable "backup_event_rule" {
  description = "CloudWatch event rule configuration (optional)."
  type = object({
    name        = string
    description = string
  })
  default = null
}

variable "event_bridge_role" {
  description = "IAM role configuration for CloudWatch EventBridge rule."
  type = object({
    name                 = string
    path                 = string
    max_session_duration = number
  })
  default = null
}

variable "lambda_function" {
  description = "Lambda function configuration for backup event processing (optional)."
  type = object({
    name        = string
    description = string
    handler     = string
    runtime     = string
    memory_size = number
    timeout     = number
    filename    = string
  })
  default = null
}

variable "lambda_function_env_variables" {
  description = "Environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "lambda_archive_file" {
  description = "Archive file info for Lambda deployment package."
  type = object({
    type        = string
    source_file = string
    output_path = string
  })
  default = null
}

variable "iam_role_lambda_backup_services" {
  description = "IAM Role name for Lambda to interact with AWS Backup."
  type        = string
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
  description = "Fallback map of vault ARNs for copy actions if not provided directly."
  type        = map(string)
  default     = {}
}

variable "backup_selection" {
  description = "Backup selection criteria per backup plan."
  type = map(object({
    plan_name            = string
    selection_tag        = optional(list(object({
      type  = string
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
    resources_arn     = list(string)
    not_resources_arn = list(string)
  }))
  default = {}
}

variable "iam_role" {
  description = "IAM role config for backup plan execution."
  type = object({
    name       = string
    policy_arn = string
  })
  default = null
}

variable "key_admin_identity" {
  type        = string
  description = "The principal element of the KMS key administrator."
  default     = "root"
}

##########################
# Naming & Tags
###########################
variable "env" {
  description = "Environment short name."
  type        = string
  default     = "d"
  validation {
    condition     = contains(["d", "p", "q", "s", "g"], var.env)
    error_message = "env must be one of 'd', 'p', 'q', 's', 'g'."
  }
}

variable "bu" {
  description = "Business unit name."
  type        = string
  default     = "ot"
  validation {
    condition     = length(var.bu) <= 5
    error_message = "The business unit name must be less than or equal to 5 characters."
  }
}

variable "app" {
  description = "Application name."
  type        = string
  default     = "bp"
  validation {
    condition     = length(var.app) <= 6
    error_message = "The app name must be less than or equal to 6 characters."
  }
}

variable "resource" {
  description = "Resource name."
  type        = string
  default     = "KMS"
  validation {
    condition     = length(var.resource) <= 15
    error_message = "The resource name must be less than or equal to 15 characters."
  }
}

variable "tenant" {
  description = "Tenant name."
  type        = string
  default     = ""
  validation {
    condition     = length(var.tenant) <= 6
    error_message = "The tenant name must be less than or equal to 6 characters."
  }
}

variable "random_alphanumeric_len" {
  description = "Length of random alphanumeric string."
  type        = number
  default     = 4
  validation {
    condition     = var.random_alphanumeric_len >= 1 && var.random_alphanumeric_len <= 4
    error_message = "The length must be between 1 and 4."
  }
}

variable "special" {
  type    = bool
  default = false
}

variable "upper" {
  type    = bool
  default = false
}

variable "number" {
  type    = bool
  default = true
}

variable "gen_no_of_names" {
  type    = number
  default = 1
}

variable "team" {
  type    = string
  default = "infra"
}

variable "program" {
  type    = string
  default = "ot"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "enabled_features" {
  type    = list(string)
  default = []
}
