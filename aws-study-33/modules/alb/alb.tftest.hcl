mock_provider "aws" {}

variables {
  name_prefix       = "example"
  target_id         = "example"
  public_subnets_id = ["example"]
  vpc_id            = "example"
}

# ロードバランサーの設定の検証
run "front_end_internal" {
  command = plan

  assert {
    condition     = aws_lb.front_end.internal == false
    error_message = "ロードバランサーのスキームに誤りがあります"
  }
}

run "front_end_listner" {
  command = plan

  assert {
    condition = (
      aws_lb_listener.front_end.port == 80 &&
      aws_lb_listener.front_end.protocol == "HTTP"
    )
    error_message = "リスナーの設定が予期していたものと一致しません"
  }
}

# ターゲットグループの検証
run "front_end_terget_group" {
  command = plan

  assert {
    condition = (
      aws_lb_target_group.front_end.port == 8080 &&
      aws_lb_target_group.front_end.protocol == "HTTP"
    )
    error_message = "リスナーの設定が予期していたものと一致しません"
  }

  assert {
    condition     = aws_lb_target_group.front_end.target_type == "instance"
    error_message = "ターゲットタイプは\"instance\"である必要があります"
  }

  assert {
    condition = length([
      for k in aws_lb_target_group.front_end.health_check :
      k
      if k.enabled
    ]) > 0
    error_message = "ヘルスチェックが有効化されていません"
  }
}

# セキュリティグループの検証
run "alb_sg_ingress" {
  command = plan

  assert {
    condition = length([
      for rule in aws_security_group.alb.ingress :
      rule
      if(
        rule.from_port == 80 &&
        rule.to_port == 80 &&
        rule.protocol == "tcp" &&
        contains(rule.cidr_blocks, "0.0.0.0/0")
      )
    ]) > 0
    error_message = "ALBのインバウンドルールが予期されているものと一致していません"
  }
}

run "alb_sg_egress" {
  command = plan

  assert {
    condition = length([
      for rule in aws_security_group.alb.egress :
      rule
      if(
        rule.from_port == 0 &&
        rule.to_port == 0 &&
        rule.protocol == "-1" &&
        contains(rule.cidr_blocks, "0.0.0.0/0")
      )
    ]) > 0
    error_message = "ALBのアウトバウンドルールが予期されているものと一致していません"
  }
}
