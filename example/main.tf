
module "aws_backup" {
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-backup.git?ref=Feature"

  source_aws_region              = var.source_aws_region
  aws_profile                   = var.aws_profile
 env = var.env
 owner = var.owner
 app = var.app
  backup_vault_name             = var.backup_vault_name
  intermediate_backup_vault_name = var.intermediate_backup_vault_name
  another_account_account_id    = var.another_account_account_id

  cmk_backup_vault              = var.cmk_backup_vault

  event_bridge_role             = var.event_bridge_role
  backup_event_rule             = var.backup_event_rule

  lambda_function               = var.lambda_function
  lambda_function_env_variables = var.lambda_function_env_variables
  lambda_archive_file           = var.lambda_archive_file

  iam_role_lambda_backup_services = var.iam_role_lambda_backup_services

  copy_backup_destination_vault_name = var.copy_backup_destination_vault_name
  backup_plan                        = var.backup_plan
  backup_selection                   = var.backup_selection
  iam_role                           = var.iam_role
}


