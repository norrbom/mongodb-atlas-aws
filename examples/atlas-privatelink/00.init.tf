terraform {
  backend "s3" {
    bucket         = "terraform-backend-atlas-poc"
    region         = "eu-north-1"
    dynamodb_table = "terraform-backend-atlas-poc"
    key            = "atlas-poc.tfstate"
  }
  required_providers {
    aws = {}
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.4.6"
    }
  }
}