provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github_oidc_provider_create" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 

  tags = var.tags
}

# IAM Role for Stage Environment
resource "aws_iam_role" "github_stage_role" {
  name = "GitHubAction-Merapar-StageRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc_provider_create.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

# IAM Policy for Stage Role
resource "aws_iam_policy" "github_stage_policy" {
  name        = "GitHubAction-Merapar-StagePolicy"
  description = "Policy for GitHub Actions to access stage environment resources for Merapar project."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissions for S3 backend state
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.stage_s3_bucket_name}"
        ]
      },
      { # Permissions for S3 backend state objects
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.stage_s3_bucket_name}/dynamic-string/stage/*"
        ]
      },
      { # Permissions for DynamoDB backend locks
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.stage_dynamodb_table_name}"
        ]
      },
      { # Permissions for application resources
        Effect = "Allow",
        Action = [
            # KMS
            "kms:CreateKey", "kms:TagResource", "kms:UntagResource", "kms:DescribeKey", "kms:EnableKeyRotation", 
            "kms:UpdateKeyDescription", # Added
            "kms:GetKeyRotationStatus", "kms:GetKeyPolicy", "kms:PutKeyPolicy", "kms:ListResourceTags", 
            "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion",
            "kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey",
            # IAM
            "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:TagRole", "iam:UntagRole", 
            "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy", 
            "iam:PutRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", 
            "iam:ListInstanceProfilesForRole", 
            "iam:PassRole",         
            # Lambda
            "lambda:CreateFunction", "lambda:DeleteFunction", "lambda:GetFunction", "lambda:GetFunctionConfiguration", 
            "lambda:UpdateFunctionConfiguration", "lambda:UpdateFunctionCode", "lambda:TagResource", 
            "lambda:UntagResource", "lambda:ListTags", "lambda:AddPermission", "lambda:RemovePermission", 
            "lambda:InvokeFunction", "lambda:ListVersionsByFunction", 
            "lambda:GetFunctionCodeSigningConfig", "lambda:PutFunctionCodeSigningConfig", "lambda:DeleteFunctionCodeSigningConfig",
            "lambda:GetPolicy",
            # API Gateway V2
            "apigateway:POST", "apigateway:GET", "apigateway:PUT", "apigateway:DELETE", "apigateway:PATCH", 
            "apigateway:TagResource", "apigateway:UntagResource",
            # SSM Parameter Store
            "ssm:PutParameter", "ssm:GetParameter", "ssm:GetParameters", "ssm:DeleteParameter", 
            "ssm:DescribeParameters", 
            "ssm:TagResource", "ssm:UntagResource", "ssm:ListTagsForResource"
        ],
        Resource = "*" 
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stage_role_policy_attach" {
  role       = aws_iam_role.github_stage_role.name
  policy_arn = aws_iam_policy.github_stage_policy.arn
}


# IAM Role for Prod Environment
resource "aws_iam_role" "github_prod_role" {
  name = "GitHubAction-Merapar-ProdRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc_provider_create.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

# IAM Policy for Prod Role
resource "aws_iam_policy" "github_prod_policy" {
  name        = "GitHubAction-Merapar-ProdPolicy"
  description = "Policy for GitHub Actions to access prod environment resources for Merapar project."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissions for S3 backend state
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.prod_s3_bucket_name}"
        ]
      },
      { # Permissions for S3 backend state objects
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.prod_s3_bucket_name}/dynamic-string/prod/*"
        ]
      },
      { # Permissions for DynamoDB backend locks
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.prod_dynamodb_table_name}"
        ]
      },
      { # Permissions for application resources
        Effect = "Allow",
        Action = [
            "kms:CreateKey", "kms:TagResource", "kms:UntagResource", "kms:DescribeKey", "kms:EnableKeyRotation", "kms:UpdateKeyDescription", "kms:GetKeyRotationStatus", "kms:GetKeyPolicy", "kms:PutKeyPolicy", "kms:ListResourceTags", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion", "kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey",
            "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:TagRole", "iam:UntagRole", "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy", "iam:PutRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole", "iam:PassRole",
            "lambda:CreateFunction", "lambda:DeleteFunction", "lambda:GetFunction", "lambda:GetFunctionConfiguration", "lambda:UpdateFunctionConfiguration", "lambda:UpdateFunctionCode", "lambda:TagResource", "lambda:UntagResource", "lambda:ListTags", "lambda:AddPermission", "lambda:RemovePermission", "lambda:InvokeFunction", "lambda:ListVersionsByFunction", "lambda:GetFunctionCodeSigningConfig", "lambda:PutFunctionCodeSigningConfig", "lambda:DeleteFunctionCodeSigningConfig", "lambda:GetPolicy",
            "apigateway:POST", "apigateway:GET", "apigateway:PUT", "apigateway:DELETE", "apigateway:PATCH", "apigateway:TagResource", "apigateway:UntagResource",
            "ssm:PutParameter", "ssm:GetParameter", "ssm:GetParameters", "ssm:DeleteParameter", "ssm:DescribeParameters", "ssm:TagResource", "ssm:UntagResource", "ssm:ListTagsForResource"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prod_role_policy_attach" {
  role       = aws_iam_role.github_prod_role.name
  policy_arn = aws_iam_policy.github_prod_policy.arn
}