terraform {
  required_providers {
    aws = {
      version = "4.40.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.6.0"
    }
  }
}