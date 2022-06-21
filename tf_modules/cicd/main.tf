# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
    count = var.enabled ? 1 : 0

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
  key_name   = "${var.environment_name}-code-deploy-demo"
  public_key = file(var.public_key_path)
}

# create a CodeDeploy application
resource "aws_codedeploy_app" "main" {
  name = "${var.environment_name}-sample-app"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "${var.environment_name}-dg"
  service_role_arn      = aws_iam_role.codedeploy_service.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime" # AWS defined deployment config

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "CodeDeployDemo"
    }
  }

  # trigger a rollback on deployment failure event
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
    ]
  }
}