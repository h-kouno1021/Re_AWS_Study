# provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.34.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# backend
terraform {
  backend "s3" {
    bucket = "h-kouno-terraform-study"
    key    = "aws-study-33/stage/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
