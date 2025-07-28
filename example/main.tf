
module "standard_tags" {
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-standard-tagging.git?ref=dev"

  bu      = var.bu
  program = var.program
  app     = var.app
  team    = var.team
  region  = var.region
  env     = var.env
}

module "naming" {
  source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"
  bu       = var.bu
  env      = var.env
  app      = var.app
  resource = var.resource
}


module "aws_backup" {
  source = "../"

  source_aws_region              = var.source_aws_region
  aws_profile                   = var.aws_profile
 bu      = var.bu
  program = var.program
  app     = var.app
  env     = var.env
  team    = var.team
  region  = var.region
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


