output "ami_parameter_arn" {
  value = aws_ssm_parameter.latest_ami_id.arn
}

output "ami_parameter_name" {
  value = aws_ssm_parameter.latest_ami_id.name
}

output "ami_parameter_value" {
  sensitive = true
  value     = aws_ssm_parameter.latest_ami_id.value
}
