terraform {
  backend "s3" {
    bucket         = "terraform-backend-atlas-external-privatelink"
    region         = "eu-north-1"
    dynamodb_table = "terraform-backend-atlas-external-privatelink"
    key            = "atlas-poc.tfstate"
  }
}