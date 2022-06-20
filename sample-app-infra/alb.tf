resource "aws_lb" "lb" {
  name               = "${var.environment_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_80.id, aws_security_group.allow_443.id]
  subnets            = module.custom_vpc.public_subnet_ids
  idle_timeout       = 10
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.environment_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.custom_vpc.vpc_id


  health_check {
    port                = 80
    healthy_threshold   = 2
    interval            = 5
    unhealthy_threshold = 2
    timeout             = 2
  }

  deregistration_delay = 1
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
