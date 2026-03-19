resource "aws_lb" "front_end" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = var.public_subnets_id
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = 80
  protocol          = "HTTP"

  # ターゲットグループに転送
  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.front_end.arn
      }
    }
  }
}

resource "aws_lb_target_group" "front_end" {
  name        = "${var.name_prefix}-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true

    matcher = "200,300,301"
    path    = "/"
  }
}
# EC2にトラフィックを振り分け
resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = var.target_id
  port             = 8080
}

resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id
  name   = "${var.name_prefix}-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
