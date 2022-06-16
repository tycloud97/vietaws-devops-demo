data "aws_ami" "amazon-linux-2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]

}

resource "aws_instance" "main" {
  ami                  = data.aws_ami.amazon-linux-2.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.main.key_name
  iam_instance_profile = aws_iam_instance_profile.main.name

  vpc_security_group_ids = [
    "${aws_security_group.http.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  tags = {
    Name = "CodeDeployDemo"
  }

  provisioner "remote-exec" {
    script = "./install_codedeploy_agent.sh"

    connection {
      host        = self.public_ip
      agent       = false
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
    }
  }
}

resource "aws_security_group" "http" {
  name        = "allow-http"
  description = "Allow all http inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow-ssh"
  description = "Allow ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_outbound" {
  name        = "allow-all-outbound"
  description = "Allow outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
  name = "codedeploy-service-role"

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
  name = "codedeploy-instance-profile"

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
  name = "codedeploy-instance-profile"
  role = aws_iam_role.instance_profile.name
}

resource "aws_key_pair" "main" {
  key_name   = "code-deploy-demo"
  public_key = file(var.public_key_path)
}

variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type that will be launched"
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to a public ssh key"
  default     = "~/.ssh/code-deploy-demo.pub"
}

variable "private_key_path" {
  description = "Path to a private ssh key"
  default     = "~/.ssh/code-deploy-demo"
}

# create a CodeDeploy application
resource "aws_codedeploy_app" "main" {
  name = "Sample_App"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "Sample_DepGroup"
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