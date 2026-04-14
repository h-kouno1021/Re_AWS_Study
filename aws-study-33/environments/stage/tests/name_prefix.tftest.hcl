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
