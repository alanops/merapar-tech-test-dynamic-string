terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Stage Environment Resources
resource "aws_s3_bucket" "state_stage" {
  bucket = "merapar-terraform-state-stage"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state_stage" {
  bucket = aws_s3_bucket.state_stage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "locks_stage" {
  name         = "merapar-terraform-locks-stage"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Prod Environment Resources
resource "aws_s3_bucket" "state_prod" {
  bucket = "merapar-terraform-state-prod"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state_prod" {
  bucket = aws_s3_bucket.state_prod.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "locks_prod" {
  name         = "merapar-terraform-locks-prod"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}