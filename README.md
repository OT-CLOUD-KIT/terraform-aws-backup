# Terraform AWS Backup

This Terraform module automates the setup of **AWS Backup**, allowing you to configure backup vaults, backup plans, selections, cross-region copies, and optional Lambda automation for backup event handling.

It supports:

- Vault creation with KMS encryption  
- Backup plan with advanced lifecycle policies  
- Optional cross-account backup copy  
- EventBridge and Lambda triggers on backup events  

---

## Prerequisites

Before using this module, ensure the following:

- IAM access to create AWS Backup, KMS, Lambda, and EventBridge resources  
- Proper subnet and networking if Lambda is used inside a VPC  
- The target AWS region is supported by AWS Backup  

---

## Architecture
![backup_1 drawio](https://github.com/user-attachments/assets/190161e7-aeb8-4099-9552-fd6d2e18b1b0)


---

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) | >= 4.0   |
| [Terraform](https://www.terraform.io/)            | >= 1.2.0 |

---

## Usage

```hcl
module "aws_backup" {
  source = "OT-CLOUD-KIT/terraform-aws-backup"

  source_aws_region                  = var.source_aws_region
  aws_profile                        = var.aws_profile

  backup_vault_name                 = var.backup_vault_name
  intermediate_backup_vault_name   = var.intermediate_backup_vault_name
  another_account_account_id       = var.another_account_account_id

  cmk_backup_vault                  = var.cmk_backup_vault

  event_bridge_role                 = var.event_bridge_role
  backup_event_rule                 = var.backup_event_rule

  lambda_function                   = var.lambda_function
  lambda_function_env_variables     = var.lambda_function_env_variables
  lambda_archive_file               = var.lambda_archive_file

  iam_role_lambda_backup_services   = var.iam_role_lambda_backup_services

  copy_backup_destination_vault_name = var.copy_backup_destination_vault_name
  backup_plan                        = var.backup_plan
  backup_selection                   = var.backup_selection

  iam_role                           = var.iam_role
}
```

## Resources

| Name                                                                                                                              | Type     |
| --------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws\_backup\_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)                    | Resource |
| [aws\_backup\_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan)                      | Resource |
| [aws\_backup\_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection)            | Resource |
| [aws\_lambda\_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)              | Resource |
| [aws\_cloudwatch\_event\_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | Resource |

___

## Input

| Name                                                                                                                                        | Description                                    | Type          | Default     | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------------- | ----------- | :------: |
| <a name="input_source_aws_region"></a> [source\_aws\_region](#input_source_aws_region)                                                      | Region for the source AWS environment          | `string`      | n/a         |     Yes    |
| <a name="input_aws_profile"></a> [aws\_profile](#input_aws_profile)                                                                         | AWS CLI profile to use                         | `string`      | `"default"` |     No    |
| <a name="input_backup_vault_name"></a> [backup\_vault\_name](#input_backup_vault_name)                                                      | Name of the main backup vault                  | `string`      | n/a         |     Yes    |
| <a name="input_intermediate_backup_vault_name"></a> [intermediate\_backup\_vault\_name](#input_intermediate_backup_vault_name)              | Optional second vault for cross-region copy    | `string`      | `null`      |     No    |
| <a name="input_another_account_account_id"></a> [another\_account\_account\_id](#input_another_account_account_id)                          | Account ID to allow cross-account copy         | `string`      | n/a         |     No    |
| <a name="input_cmk_backup_vault"></a> [cmk\_backup\_vault](#input_cmk_backup_vault)                                                         | Configuration for KMS CMK used by backup vault | `map(any)`    | `{}`        |     Yes    |
| <a name="input_event_bridge_role"></a> [event\_bridge\_role](#input_event_bridge_role)                                                      | IAM Role for EventBridge to trigger Lambda     | `map(any)`    | `{}`        |     No    |
| <a name="input_backup_event_rule"></a> [backup\_event\_rule](#input_backup_event_rule)                                                      | Backup event rule details (name, desc)         | `map(any)`    | `{}`        |     No    |
| <a name="input_lambda_function"></a> [lambda\_function](#input_lambda_function)                                                             | Lambda function config triggered after backup  | `map(any)`    | `{}`        |     No    |
| <a name="input_lambda_archive_file"></a> [lambda\_archive\_file](#input_lambda_archive_file)                                                | Archive settings for Lambda zip                | `map(any)`    | `{}`        |     No    |
| <a name="input_lambda_function_env_variables"></a> [lambda\_function\_env\_variables](#input_lambda_function_env_variables)                 | Environment variables for Lambda               | `map(string)` | `{}`        |     No    |
| <a name="input_iam_role_lambda_backup_services"></a> [iam\_role\_lambda\_backup\_services](#input_iam_role_lambda_backup_services)          | IAM role name for Lambda execution             | `string`      | n/a         |     No    |
| <a name="input_copy_backup_destination_vault_name"></a> [copy\_backup\_destination\_vault\_name](#input_copy_backup_destination_vault_name) | Map of copy action vaults per region           | `map(string)` | `{}`        |     Yes    |
| <a name="input_backup_plan"></a> [backup\_plan](#input_backup_plan)                                                                         | Map of backup plan configurations              | `map(any)`    | `{}`        |     Yes    |
| <a name="input_backup_selection"></a> [backup\_selection](#input_backup_selection)                                                          | Map of selection tags/resources per plan       | `map(any)`    | `{}`        |     Yes    |
| <a name="input_iam_role"></a> [iam\_role](#input_iam_role)                                                                                  | IAM Role used by AWS Backup for selection      | `map(any)`    | `{}`        |     Yes    |


___

## Output

| Name                                                                                                                          | Description                                                   |
| ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| <a name="output_intermediate_backup_vault_arn"></a> [intermediate\_backup\_vault\_arn](#output_intermediate_backup_vault_arn) | ARN of the intermediate backup vault (if created)             |
| <a name="output_account_id"></a> [account\_id](#output_account_id)                                                            | AWS Account ID where the module is executed                   |
| <a name="output_backup_vault_arn"></a> [backup\_vault\_arn](#output_backup_vault_arn)                                         | ARN of the main AWS Backup vault                              |
| <a name="output_backup_role_arn"></a> [backup\_role\_arn](#output_backup_role_arn)                                            | IAM Role ARN used by the Lambda function for AWS Backup tasks |

___

## Contributors

- [Piyush Upadhyay](https://github.com/piiiyuushh)
- [Nikita Joshi](https://github.com/jnikita19)

