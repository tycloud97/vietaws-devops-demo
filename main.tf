provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
    backend "s3" {
        bucket = "827539266883-terraform-state"
        encrypt = true
        key = "terraform.tfstate"
        region = "ap-southeast-1"
    }
  required_version = ">= 0.14.9"
}



data "aws_caller_identity" "current" {}

module "cicd_front_end" {
  source   = "./tf_modules/cicd"
  app_name = "front-end"
}
