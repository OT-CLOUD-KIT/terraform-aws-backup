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


variable "owner" {
 type = string
 default = "opstree"
}

variable "env" {
  type = string
  default = "dev"
}

variable "app" {
  type = string
  default = "otcloud-kit"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
