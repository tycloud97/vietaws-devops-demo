provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_providers {

    random = {
      source  = "hashicorp/random"
      version = "3.3.1"
    }

    aws = {
      version = "~> 3.27"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {}

  # backend "s3" {
  #   bucket  = "827539266883-terraform-state"
  #   encrypt = true
  #   key     = "terraform22.tfstate"
  #   region  = "ap-southeast-1"
  # }
  required_version = ">= 1.2.3"

}

module "custom_vpc" {
  source = "../tf_modules/terraform-module-vpc"

  prefix         = var.environment_name
  separator      = "-"
  name           = "main"
  vpc_cidr_block = var.vpc_cidr_block

  first_private_subnet_cidr  = var.first_private_subnet_cidr
  second_private_subnet_cidr = var.second_private_subnet_cidr

  first_public_subnet_cidr  = var.first_public_subnet_cidr
  second_public_subnet_cidr = var.second_public_subnet_cidr
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
  name = "${var.environment_name}-codedeploy-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# create a service role for ec2 
resource "aws_iam_role" "instance_profile" {
  name = "${var.environment_name}-codedeploy-instance-profile"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# provide ec2 access to s3 bucket to download revision. This role is needed by the CodeDeploy agent on EC2 instances.
resource "aws_iam_role_policy_attachment" "instance_profile_codedeploy" {
  role       = aws_iam_role.instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.environment_name}-codedeploy-instance-profile"
  role = aws_iam_role.instance_profile.name
}

resource "aws_key_pair" "main" {
  key_name = "${var.environment_name}-code-deploy-demo"
  # public_key = file(var.public_key_path)
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfa4qkxGj8cFfJZ30/ZKt69rvfhFxtN6ChS2K8roBGD18Gua1VseCd7MjRaBKjW2HUu7kwPpuFIZabH4X3UJA/TPBWCLBYKzcdfhaxS8oLjqDxumJjT9+JatuAXaVqkAz3YVHlX5Q5ulBjT551Fm0Ke0GGg9X3Cbwwi4zCE5QJnypO41D+acEI3AmHxkA6DI51OccZ6L7kvgcN5kIM0BEU9BCeJe2GOa9pPqG0PT7e6vKWp9NwLwP3SvBWz4AHaFBZsyHahP2LK9JPCbjrlYSkT1bMhLKu1Bcm4YWtmC2hMC7qL77tF4mql16V1nZsdsmAROgLWllpfzRXBvpMb/gBdotNIT7IymbwU6z/bWX1NP/b5AoUTLXyhW/ERyFEJTHiOkBCLI6uTUiWjeDD4t6a/xvpahWgGiBnyfymLovhcRe9cA7n39xAdr6evs4r15BJ70A3HRFLVn7JklXSHg39DY4WoZdERPc8bY5GPLvjEhcLnq+ikPR/wV1RW7nUwU8= cd-demo"
}

# create a CodeDeploy application
# resource "aws_codedeploy_app" "main" {
#   name = "${var.environment_name}-sample-app"
# }

# # create a deployment group
# resource "aws_codedeploy_deployment_group" "main" {
#   app_name              = aws_codedeploy_app.main.name
#   deployment_group_name = "${var.environment_name}-dg"
#   service_role_arn      = aws_iam_role.codedeploy_service.arn

#   deployment_config_name = "CodeDeployDefault.AllAtOnce" # AWS defined deployment config

#   ec2_tag_set {
#     ec2_tag_filter {
#       key   = "Name"
#       type  = "KEY_AND_VALUE"
#       value = "CodeDeployDemo"
#     }
#   }

#   # trigger a rollback on deployment failure event
#   auto_rollback_configuration {
#     enabled = true
#     events = [
#       "DEPLOYMENT_FAILURE",
#     ]
#   }
# }