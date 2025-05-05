variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "dynamic_string_initial" {
  description = "Initial value for the dynamic string"
  type        = string
  default     = "hello world"
}

variable "parameter_name" {
  description = "SSM parameter path"
  type        = string
  default     = "/merapar/dynamicString"
}

variable "environment" {
  description = "Deployment environment (stage/prod)"
  type        = string
  default     = "stage"
  validation {
    condition     = contains(["stage", "prod"], var.environment)
    error_message = "Environment must be one of: stage, prod"
  }
}

variable "log_level" {
  description = "Lambda function log level"
  type        = string
  default     = "INFO"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "iam_permissions_boundary_arn" {
  description = "ARN of IAM permissions boundary to apply to roles"
  type        = string
  default     = null
}
