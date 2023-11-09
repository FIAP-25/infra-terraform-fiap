################################################################################
# Load Balancer
################################################################################
resource "aws_lb" "my_load_balancer" {
  name               = "fiap-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = aws_subnet.private_subnet.*.id
  security_groups    = [aws_security_group.security_group_alb.id]
}

resource "aws_lb_target_group" "my_load_balancer_target_group" {
  name        = "fiap-target-group"
  port        = 3000 # Match with the container port
  protocol    = "HTTP"
  target_type = "ip"         # Set the target type to "ip" for Fargate
  vpc_id      = local.vpc_id # Add your VPC ID here

  health_check {
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "my_load_balancer_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_load_balancer_target_group.arn
  }
}

resource "aws_security_group" "security_group_alb" {
  name        = "fiap-sg-alb"
  description = "Balancer Security Group"
  vpc_id      = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
