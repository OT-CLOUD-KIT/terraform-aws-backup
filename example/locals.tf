locals {
  copy_backup_destination_vault_name = {
    "copy_different_region" = module.destination.backup_vault_arn
  }
}