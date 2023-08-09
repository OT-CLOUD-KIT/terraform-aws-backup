module "source_backup" {
  source                             = "path to module"
  aws_profile                        = ""
  backup_vault_name                  = var.source_backup_vault_name
  source_aws_region                  = var.source_aws_region
  another_account_account_id         = module.destination.account_id
  key_admin_identity                 = var.key_admin_identity
  backup_plan                        = var.backup_plan
  backup_selection                   = var.backup_selection
  copy_backup_destination_vault_name = local.copy_backup_destination_vault_name
}

module "destination" {
  source                     = "path to module"
  aws_profile                = ""
  backup_vault_name          = var.destination_backup_vault_name
  another_account_account_id = module.source_backup.account_id
  source_aws_region          = var.destination_aws_region
}