resource "aws_codecommit_repository" "codecommit" {
  repository_name = "viet-aws-${var.app_name}"
  description     = "This is the BookStore App ${var.app_name} Repository"
}