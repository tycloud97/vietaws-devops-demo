resource "aws_lb" "lb" {
  name               = "${var.project_name}-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_80.id, aws_security_group.allow_443.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

#   tags = var.required_tags
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id


  stickiness {
      type = "lb_cookie"
  }

  health_check {
    port = 80
  }

  deregistration_delay = 60
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "alb_url" {
  value = aws_lb.lb.dns_name
}