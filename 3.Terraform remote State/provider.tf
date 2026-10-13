terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "local" {

  }

  #   backend "s3" {

  #     # bucket = "ashelga-s3-bucket-09090989899"
  #     # key = "terraform.tfstate"
  #     # region = "ap-south-1"
  #   }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}