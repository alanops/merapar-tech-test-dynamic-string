variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "eu-west-1"
}

variable "github_org" {
  description = "Your GitHub organization name."
  type        = string
  default     = "alanops"
}

variable "github_repo" {
  description = "Your GitHub repository name (without the organization)."
  type        = string
  default     = "merapar-tech-test-dynamic-string"
}

variable "stage_s3_bucket_name" {
  description = "Name of the S3 bucket for stage environment state."
  type        = string
  default     = "merapar-terraform-state-stage"
}

variable "prod_s3_bucket_name" {
  description = "Name of the S3 bucket for prod environment state."
  type        = string
  default     = "merapar-terraform-state-prod"
}

variable "stage_dynamodb_table_name" {
  description = "Name of the DynamoDB table for stage environment locks."
  type        = string
  default     = "merapar-terraform-locks-stage"
}

variable "prod_dynamodb_table_name" {
  description = "Name of the DynamoDB table for prod environment locks."
  type        = string
  default     = "merapar-terraform-locks-prod"
}

variable "tags" {
  description = "A map of tags to assign to created resources."
  type        = map(string)
  default = {
    Terraform   = "true"
    Project     = "MeraparTechTest"
    Purpose     = "GitHubActionsIAM"
  }
}