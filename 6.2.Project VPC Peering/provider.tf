terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary region: Mumbai
provider "aws" {
  region = var.mumbai_region

  default_tags {
    tags = var.tags
  }
}

# Secondary region: N. Virginia
provider "aws" {
  alias  = "virginia"
  region = var.virginia_region

  default_tags {
    tags = var.tags
  }
}
