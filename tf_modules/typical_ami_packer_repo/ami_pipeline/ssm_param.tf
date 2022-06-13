resource "aws_ssm_parameter" "gh_token" {
  name  = "/demo/ec2/gh_token"
  type  = "SecureString"
  value = var.github_token
}
