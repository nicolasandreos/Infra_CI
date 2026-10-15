terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.41"
    }
  }

  required_version = ">= 1.5.7"
}

provider "aws" {
  region = "us-west-2"
}
