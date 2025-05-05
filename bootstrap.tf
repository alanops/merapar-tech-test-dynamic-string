# Phase 1: Create state resources (use with local backend)
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
  
  default_tags {
    tags = {
      Environment = "bootstrap"
      Project     = "merapar-dynamic-string"
    }
  }
}

resource "aws_s3_bucket" "state" {
  bucket = "merapar-terraform-state"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
      versioning
    ]
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "locks" {
  name         = "merapar-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [tags]
  }
}