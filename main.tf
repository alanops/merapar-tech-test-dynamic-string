locals {
  name_prefix      = "merapar-${var.environment}"
  parameter_name_env = "/merapar/${var.environment}/dynamicString" # Environment-specific parameter name
}

provider "aws" {
  alias  = "main"
  region = var.region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "merapar-dynamic-string"
    }
  }
}

resource "aws_kms_key" "ssm" {
  description             = "KMS key for SSM parameter encryption for ${var.environment}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_ssm_parameter" "dynamic" {
  name        = local.parameter_name_env # Use environment-specific name
  type        = "SecureString"
  value       = var.dynamic_string_initial
  overwrite   = true
  key_id      = aws_kms_key.ssm.key_id
  
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "lambda_ssm" {
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_ssm.json
}

data "aws_iam_policy_document" "lambda_ssm" {
  statement {
    actions   = ["ssm:GetParameter"]
    # The aws_ssm_parameter.dynamic.arn will correctly reflect the new name
    resources = [aws_ssm_parameter.dynamic.arn] 
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.ssm.arn]
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "web" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.name_prefix}-dynamic-string"
  handler          = "handler.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      # Pass the environment-specific parameter name to the Lambda
      STRING_PARAM_NAME = aws_ssm_parameter.dynamic.name 
    }
  }
}

resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.web.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "any_root" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "prod" { # Note: This stage name is static "$default"
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default" # This is fine, as API Gateway stages are per-API.
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  function_name = aws_lambda_function.web.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}