variable "app_name" {
  description = "App name of the Pipeline"
  type        = string
}


variable "code_commit_branch" {
  description = "Branch to use for CI/CD Pipeline"
  default     = "master"
  type        = string
}
variable "environment_name" {
  type        = string
  description = "Environment name"
  default     = "common"
}

variable "enabled" {
  default = false
}

variable "instance_type" {
  description = "EC2 instance type that will be launched"
  default     = "t4g.small"
}
