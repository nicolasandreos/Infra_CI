resource "aws_lb" "alb" {
  name            = "ECS-Go"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets

  depends_on = [module.vpc]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvo.arn
  }
}

resource "aws_lb_target_group" "alvo" {
  name                 = "ECS-Go"
  port                 = local.app_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 30
  health_check {
    path                = "/nicolas"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

output "IP" {
  value = aws_lb.alb.dns_name
}
