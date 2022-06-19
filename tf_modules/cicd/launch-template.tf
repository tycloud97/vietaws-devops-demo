

data "template_file" "userdata" {
  template = "${file("./install_codedeploy_agent.sh")}"
}

resource "aws_launch_template" "launch_template" {
  
  name = var.launch_template_name
  
  image_id                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.main.key_name

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
    Name = "CodeDeployDemo"
  }
  }

  user_data = base64encode(data.template_file.userdata.rendered)
}