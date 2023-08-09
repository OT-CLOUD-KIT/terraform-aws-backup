variable "source_aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "destination_aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "key_admin_identity" {
  type    = string
  default = "root"
}

variable "source_backup_vault_name" {
  type    = string
  default = "ec2-backup-vault"
}

variable "destination_backup_vault_name" {
  type    = string
  default = "ec2-backup-vault"
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
  default = {
    "ec2-backup-plan" = {
      rules = {
        "daily-backup" = {
          rule_name         = "daily"
          target_vault_name = "ec2-backup-vault"
          schedule          = "cron(30 19 * * ? *)"
          start_window      = 60
          completion_window = 180
          lifecycle = {
            delete_after = 2
          }
          recovery_point_tags = {
            "Type" = "Prod-EC2-Instance"
          }
          copy_action = {
            "copy_different_region" = {
              lifecycle = {
                delete_after = 2
              }
            }
          }
        }
      }
      tags = {
        "Name"      = "EC2-backup-plan"
        "ManagedBy" = "Terraform"
        "Purpose"   = "Backup"
      }
    }
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
  default = {
    "prod-ec2" = {
      plan_name = "ec2-backup-plan"
      resources_arn = [
       
      ]
    }
  }
}
