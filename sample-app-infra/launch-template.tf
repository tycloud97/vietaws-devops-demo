

data "template_file" "userdata" {
  template = file("./install_codedeploy_agent.sh")
}

# create a service role for ec2 
resource "aws_iam_role" "instance_profile" {
  name = "${var.environment_name}-${var.app_name}-instance-profile"

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
  name = "${var.environment_name}-${var.app_name}-instance-profile"
  role = aws_iam_role.instance_profile.name
}

resource "aws_launch_template" "launch_template" {

  name = "${var.environment_name}-${var.app_name}-lt"

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }


  vpc_security_group_ids = [
    "${aws_security_group.http.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment_name}-${var.app_name}-instance"
    }
  }

  user_data = base64encode(data.template_file.userdata.rendered)
}