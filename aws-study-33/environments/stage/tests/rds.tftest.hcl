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

run "rds_ingress_allow_ec2" {
  command = plan

  variables {
    ec2_sg_id = "example"
  }

  assert {
    condition = length([
      for rule in aws_security_group.rds.ingress :
      rule
      if(
        rule.from_port == 3306 &&
        rule.to_port == 3306 &&
        rule.protocol == "tcp" &&
        contains(rule.security_groups, "example")
      )
    ]) > 0
    error_message = "RDSのインバウンドルールが予期されているものと一致していません"
  }
}

run "rds_egress_allow_all" {
  command = plan

  assert {
    condition = length([
      for rule in aws_security_group.rds.egress :
      rule
      if(
        rule.from_port == 0 &&
        rule.to_port == 0 &&
        rule.protocol == "-1" &&
        contains(rule.cidr_blocks, "0.0.0.0/0")
      )
    ]) > 0
    error_message = "RDSのアウトバウンドルールが予期されているものと一致していません"
  }
}
