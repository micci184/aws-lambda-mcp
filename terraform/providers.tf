terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.25"
    }
  }

  # Backend is local by default.
  # To use S3 backend, create backend.tf
}

provider "aws" {
  region = var.aws_region
}
