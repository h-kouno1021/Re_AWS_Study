variables {
  name_prefix                      = "example"
  web_acl_association_resource_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/example/example"
}

run "main_web_acl_scope" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.main.scope == "REGIONAL"
    error_message = "WebACLのスコープは\"REGIONAL\"である必要があります"
  }
}

# ロググループの検証
run "waf_log_gloup" {
  command = plan

  assert {
    condition     = strcontains(aws_cloudwatch_log_group.waf.name, "aws-waf-logs-")
    error_message = "ロググループ名は\"aws-waf-logs-\"から始まる必要があります"
  }
}
