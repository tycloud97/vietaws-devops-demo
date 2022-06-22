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
  # backend "s3" {}
  backend "s3" {
    bucket  = "827539266883-terraform-state"
    encrypt = true
    key     = "terraform12233.tfstate"
    region  = "ap-southeast-1"
  }
  required_version = ">= 1.2.3"
}

data "aws_caller_identity" "current" {}

module "cicd_sample_app" {
  enabled  = true
  source   = "./tf_modules/cicd"
  app_name = "sample-app"
}

output "repository_url" {
  description = "URL of Code Commit Repository for Resource API."
  value       = module.cicd_sample_app.repository_url
}


module "cicd_webhook" {
  source = "./tf_modules/codepipeline-git-webhook"
  name   = "webhook-devops"
  stage  = "main"

  github_repositories        = ["vietaws-devops-demo"]
  github_default_branch_name = "main"

  webhook_secret            = "AAABBBCCCDDD"
  codebuild_target_pipeline = aws_codepipeline.cicd_pipeline.id
}