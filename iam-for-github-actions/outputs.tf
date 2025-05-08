output "github_stage_role_arn" {
  description = "ARN of the IAM role for GitHub Actions (Stage Environment)."
  value       = aws_iam_role.github_stage_role.arn
}

output "github_prod_role_arn" {
  description = "ARN of the IAM role for GitHub Actions (Prod Environment)."
  value       = aws_iam_role.github_prod_role.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC Provider."
  value       = aws_iam_openid_connect_provider.github_oidc_provider_create.arn
}