terraform {
  required_providers {
    aws = {}
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.4.6"
    }
  }
}

data "aws_caller_identity" "current" {}