resource "aws_autoscaling_group" "asg" {
  name                      = "${var.environment_name}-${var.app_name}-asg"
  max_size                  = 2
  min_size                  = 0
  desired_capacity          = 1
  health_check_grace_period = 5
  health_check_type         = "ELB"
  vpc_zone_identifier       = module.custom_vpc.public_subnet_ids

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = all
  }
}
