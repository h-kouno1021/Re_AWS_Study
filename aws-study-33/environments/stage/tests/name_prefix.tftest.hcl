variables {
  my_env    = "stage"
  my_ip     = "60.94.251.76"
  pj_prefix = "raisetech"

  vpc_cidr_block = "10.0.0.0/16"

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

# 名前のプレフィックスの検証
run "name_prefix" {
  command = plan

  assert {
    condition     = local.name_prefix == "raisetech-terraform-stage"
    error_message = "名前のプレフィックスが違います"
  }
}

# 環境名の検証
run "my_env" {
  command = plan

  variables {
    my_env = "prod"
  }
}

run "my_env_invalid" {
  command = plan

  # 無効な値を変数に入れた時に失敗することを確認
  variables {
    my_env = "dev"
  }

  expect_failures = [var.my_env]
}
