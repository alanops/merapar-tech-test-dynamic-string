terraform {
  backend "s3" {
    bucket         = "merapar-terraform-state"
    key            = "dynamic-string/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "merapar-terraform-locks"
    encrypt        = true
  }
}