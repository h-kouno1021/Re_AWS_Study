data "aws_ssm_parameter" "ami_al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "ec2" {
  ami                     = data.aws_ssm_parameter.ami_al2023.value
  instance_type           = var.ec2_instance_config
  tenancy                 = "default"
  key_name                = var.key_name
  disable_api_termination = false

  subnet_id              = module.vpc.public_subnet_ids["public-1a"]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    "Name" = "${local.name_prefix}-ec2"
  }
}

# SecuriryGroup
resource "aws_security_group" "ec2_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${local.name_prefix}-ec2-sg"

  tags = {
    Name = "${local.name_prefix}-ec2-sg"
  }
}

# ingress_rule

locals {
  # 接続を許可するALBのセキュリティグループIDの値の条件分岐
  alb_sg_id = (var.alb_sg_id != null
    ? var.alb_sg_id
    : module.alb.lb_security_group_id
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ec2_sg.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "${var.my_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb" {
  security_group_id = aws_security_group.ec2_sg.id

  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = local.alb_sg_id
}

# egress_rule
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.ec2_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# CPU使用率に対するアラーム設定
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_ec2" {
  alarm_description = "${aws_instance.ec2.id}のCPU使用率が1%以上になりました。"
  alarm_name        = "${local.name_prefix}-EC2-CPUUtilization-Alarm"

  namespace = "AWS/EC2"
  dimensions = {
    "InstanceId" = aws_instance.ec2.id
  }
  metric_name = "CPUUtilization"
  unit        = "Percent"

  # 60秒間の平均値からデータポイントを算出します
  statistic = "Average"
  period    = 60
  # 直近5つのデータポイントのうち1つがしきい値以上になった時にアラームを発行します
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 5
  datapoints_to_alarm = 1

  treat_missing_data = "missing"

  # 指定のEメールアドレス宛にアラームの通知を送信します
  actions_enabled = true
  alarm_actions   = [aws_sns_topic.email.arn]
}

resource "aws_sns_topic" "email" {
  name = "${local.name_prefix}-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.email.arn

  endpoint = var.subscribes_email_address
  protocol = "email"
}
