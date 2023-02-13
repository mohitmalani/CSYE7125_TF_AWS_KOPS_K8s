provider "aws" {
  region  = var.region
  profile = var.awscli-profile
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">=4.0, <5.0"
    }
  }
}