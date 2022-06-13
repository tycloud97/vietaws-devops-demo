
terraform {
  backend "s3" {
    bucket         = "terraform-projects-state"
    key            = "demo/ami_packer_support.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock-table"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.70"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = {
      "Env"         = "dev",
      "Owner"       = "cherrera",
      "Provisioner" = "terraform",
      "Project"     = "Packer Demo AMI Pipeline Infra Support"
    }
  }
}

