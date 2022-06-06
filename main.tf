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

  required_version = ">= 0.14.9"
}

data "aws_caller_identity" "current" {}

module "cicd_front_end" {
  source   = "./tf_modules/cicd"
  app_name = "front-end"
}
