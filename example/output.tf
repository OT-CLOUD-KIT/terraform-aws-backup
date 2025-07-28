output "intermediate_backup_vault_arn" {
  description = "ARN of the intermediate backup vault, if created"
  value       = module.aws_backup.intermediate_backup_vault_arn
}

output "account_id" {
  description = "AWS Account ID from the caller identity"
  value       = module.aws_backup.account_id
}

output "backup_vault_arn" {
  description = "ARN of the primary backup vault"
  value       = module.aws_backup.backup_vault_arn
}

output "backup_role_arn" {
  description = "IAM Role ARN used by the Lambda for backup copy"
  value       = module.aws_backup.backup_role_arn
}
