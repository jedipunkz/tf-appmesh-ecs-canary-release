resource "aws_lb" "example" {
  name                       = "example"
  load_balancer_type         = "network"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = module.vpc.public_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.example.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "example" {
  name                 = "example"
  vpc_id               = module.vpc.vpc_id
  target_type          = "ip"
  port                 = 80
  protocol             = "TCP"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 5
    interval            = 30
    protocol            = "TCP"
    port                = 9080
  }

  depends_on = [aws_lb.example]
}

