
variable "first_private_subnet_cidr" {
  default = "10.50.10.0/24"
}

variable "second_private_subnet_cidr" {
  default = "10.50.11.0/24"
}

variable "first_public_subnet_cidr" {
  default = "10.50.20.0/24"
}

variable "second_public_subnet_cidr" {
  default = "10.50.21.0/24"
}


variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type that will be launched"
  default     = "t4g.small"
}

variable "app_name" {
  default = "sample-app"
  type    = string
}
variable "environment_name" {
  type    = string
  default = "dev"
}

variable "vpc_cidr_block" {
  default = "10.50.0.0/16"
}
