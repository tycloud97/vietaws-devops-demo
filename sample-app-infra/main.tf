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


resource "aws_key_pair" "main" {
  key_name   = "${var.environment_name}-${var.app_name}-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfa4qkxGj8cFfJZ30/ZKt69rvfhFxtN6ChS2K8roBGD18Gua1VseCd7MjRaBKjW2HUu7kwPpuFIZabH4X3UJA/TPBWCLBYKzcdfhaxS8oLjqDxumJjT9+JatuAXaVqkAz3YVHlX5Q5ulBjT551Fm0Ke0GGg9X3Cbwwi4zCE5QJnypO41D+acEI3AmHxkA6DI51OccZ6L7kvgcN5kIM0BEU9BCeJe2GOa9pPqG0PT7e6vKWp9NwLwP3SvBWz4AHaFBZsyHahP2LK9JPCbjrlYSkT1bMhLKu1Bcm4YWtmC2hMC7qL77tF4mql16V1nZsdsmAROgLWllpfzRXBvpMb/gBdotNIT7IymbwU6z/bWX1NP/b5AoUTLXyhW/ERyFEJTHiOkBCLI6uTUiWjeDD4t6a/xvpahWgGiBnyfymLovhcRe9cA7n39xAdr6evs4r15BJ70A3HRFLVn7JklXSHg39DY4WoZdERPc8bY5GPLvjEhcLnq+ikPR/wV1RW7nUwU8= cd-demo"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.environment_name}-${var.app_name}-vietaws-2022"
}
