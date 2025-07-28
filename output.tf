output "intermediate_backup_vault_arn" {
  value = var.intermediate_backup_vault_name != null ? aws_backup_vault.intermediate_backup_vault[0].arn : ""
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "backup_vault_arn" {
  value = aws_backup_vault.backup_vault.arn
}

output "backup_role_arn" {
  value = var.lambda_function != null ? aws_iam_role.backup_copy_manager_role[0].arn : ""
}