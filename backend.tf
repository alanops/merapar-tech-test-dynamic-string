terraform {
  backend "s3" {
    region  = "eu-west-1"
    encrypt = true
    # The following will be provided via -backend-config in the CI/CD pipeline:
    # bucket         = "merapar-terraform-state-ENV"
    # key            = "dynamic-string/ENV/terraform.tfstate"
    # dynamodb_table = "merapar-terraform-locks-ENV"
  }
}
