# =====================
# variables.tf
# =====================

variable "source_aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name"
}

variable "backup_vault_name" {
  type        = string
  description = "Name of the main backup vault"
}

variable "intermediate_backup_vault_name" {
  type        = string
  description = "Name of intermediate backup vault (optional)"
  default     = null
}

variable "another_account_account_id" {
  type        = string
  description = "AWS Account ID of another account allowed to copy backups"
}

variable "cmk_backup_vault" {
  type = object({
    enable_key_rotation = bool
    description         = string
    multi_region        = bool
  })
  description = "KMS key configuration for backup vault"
}

variable "event_bridge_role" {
  type = object({
    name                 = string
    path                 = string
    max_session_duration = number
  })
  description = "IAM role for EventBridge"
}

variable "backup_event_rule" {
  type        = any
  description = "CloudWatch event rule config (set to null if not used)"
  default     = null
}

variable "lambda_function" {
  type        = any
  description = "Lambda function configuration (set to null if not used)"
  default     = null
}

variable "lambda_function_env_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}

variable "lambda_archive_file" {
  type = object({
    type        = string
    source_file = string
    output_path = string
  })
  description = "Lambda archive configuration"
  default     = null
}

variable "iam_role_lambda_backup_services" {
  type        = string
  description = "IAM Role name used by Lambda for backup services"
}

variable "copy_backup_destination_vault_name" {
  type        = map(string)
  description = "Destination vault ARNs for backup copy operations"
}

variable "backup_plan" {
  type        = any
  description = "Backup plan definitions"
}

variable "backup_selection" {
  type        = any
  description = "Backup selection definitions"
}

variable "iam_role" {
  type = object({
    name       = string
    policy_arn = string
  })
  description = "IAM role to be used with backup selections"
}


variable "env" {
  description = "Environment short name. Must be one of: d (dev), p (prod), q (qa), s (stage), g (global)."
  type        = string
  default     = "d"
  validation {
    condition     = contains(["d", "p", "q", "s", "g"], var.env)
    error_message = "env must be one of 'd', 'p', 'q', 's', 'g'."
  }
}

variable "bu" {
  description = "Business unit name (e.g., pcs, ultrasound). Max 5 characters."
  type        = string
  default     = "ot"
  validation {
    condition     = length(var.bu) <= 5
    error_message = "The business unit name must be less than or equal to 5 characters."
  }
}

variable "app" {
  description = "Application name (e.g., network, shared). Max 6 characters."
  type        = string
  default     = "bp"
  validation {
    condition     = length(var.app) <= 6
    error_message = "The app name must be less than or equal to 6 characters."
  }
}

variable "resource" {
  description = "Resource name (e.g., eks, efs, ecr). Max 15 characters."
  type        = string
  default     = "instance"
  validation {
    condition     = length(var.resource) <= 15
    error_message = "The resource name must be less than or equal to 15 characters."
  }
}

variable "tenant" {
  description = "Tenant name (e.g., app1, app2). Max 6 characters."
  type        = string
  default     = ""
  validation {
    condition     = length(var.tenant) <= 6
    error_message = "The tenant name must be less than or equal to 6 characters."
  }
}

variable "enabled_features" {
  type    = list(string)
  default = []
}

variable "random_alphanumeric_len" {
  description = "The length of random alphanumeric string desired. Min: 1, Max: 4."
  type        = number
  default     = 4
  validation {
    condition     = var.random_alphanumeric_len >= 1 && var.random_alphanumeric_len <= 4
    error_message = "The length must be between 1 and 4."
  }
}

variable "special" {
  description = "Include special characters like !@#$%&*()-_=+[]{}<>:? in the generated name."
  type        = bool
  default     = false
}

variable "upper" {
  description = "Include uppercase characters in the generated name."
  type        = bool
  default     = false
}

variable "number" {
  description = "Include numbers in the generated name."
  type        = bool
  default     = true
}

variable "gen_no_of_names" {
  description = "Number of names to generate."
  type        = number
  default     = 1
}

variable "team" {
  description = "The email address of the team who owns the application, ex:digitalops@gehealthcare.com"
  type        = string
  default     = "infra"
}

variable "program" {
  description = "Name of the Program, For ex: OT, BP etc."
  type        = string
  default     = "ot"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
