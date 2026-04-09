mock_provider "aws" {
  source = "./tests"
}

variables {
  vpc_cidr_block = "10.0.0.0/16"
  my_env         = "stage"
  my_ip          = "60.94.251.76"
  pj_prefix      = "raisetech"

  # EC2
  ec2_instance_config = "t2.micro"
  key_name            = "example"

  # RDS
  rds_instance_config            = "db.t4g.micro"
  rds_multi_az                   = "false"
  rds_enable_deletion_protection = "false"
  rds_db_name                    = "example"

  subscribes_email_address = "example"
  rds_db_password          = "example"
  rds_db_username          = "example"
}

# インスタンスタイプの検証
run "instance_type" {
  command = plan

  assert {
    condition     = aws_instance.ec2.instance_type == "t2.micro"
    error_message = "インスタンスタイプが予期されているものと一致しません"
  }
}

# セキュリティグループルールの検証
run "ec2-sg_ingress_allow_ssh" {
  command = plan

  assert {
    condition = (
      aws_vpc_security_group_ingress_rule.allow_ssh.from_port == 22 &&
      aws_vpc_security_group_ingress_rule.allow_ssh.to_port == 22
    )
    error_message = "SSH用のポート設定が予期されているものと一致していません"
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.allow_ssh.ip_protocol == "tcp"
    error_message = "SSHの通信プロトコルはTCPである必要があります"
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.allow_ssh.cidr_ipv4 == "${var.my_ip}/32"
    error_message = "SSH接続を許可するIPアドレスが予期されているものと一致しません"
  }
}

run "ec2-sg_ingress_allow_alb" {
  command = plan

  variables {
    alb_sg_id = "example"
  }

  assert {
    condition = (
      aws_vpc_security_group_ingress_rule.allow_alb.from_port == 8080 &&
      aws_vpc_security_group_ingress_rule.allow_alb.to_port == 8080
    )
    error_message = "ALB用のポート設定が予期されているものと一致していません"
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.allow_alb.ip_protocol == "tcp"
    error_message = "ALBとEC2間の通信プロトコルはTCPである必要があります"
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.allow_alb.referenced_security_group_id != null
    error_message = "参照するセキュリティグループが設定されていません"
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.allow_alb.referenced_security_group_id == "example"
    error_message = "接続を許可するセキュリティグループの設定が不正です"
  }
}

run "ec2_sg_egress_allow_all" {
  command = plan

  assert {
    condition = (
      aws_vpc_security_group_egress_rule.allow_all.ip_protocol == "-1"
    )
    error_message = "アウトバウンドルールが予期されているものと一致していません"
  }

  assert {
    condition = (
      aws_vpc_security_group_egress_rule.allow_all.cidr_ipv4 == "0.0.0.0/0"
    )
    error_message = "アウトバウンドルールが予期されているものと一致していません"
  }
}
