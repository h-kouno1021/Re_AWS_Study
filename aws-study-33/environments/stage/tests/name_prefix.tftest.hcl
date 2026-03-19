variables {
  pj_prefix = "raisetech"
  my_env    = "stage"
}

# 名前のプレフィックスの検証
run "name_prefix" {
  command = plan

  assert {
    condition     = local.name_prefix == "raisetech-terraform-stage"
    error_message = "名前のプレフィックスが違います"
  }
}

# 無効な値を変数に入れる
run "my_env_invalid" {
  command = plan

  variables {
    my_env = "dev"
  }

  expect_failures = [var.my_env]
}
