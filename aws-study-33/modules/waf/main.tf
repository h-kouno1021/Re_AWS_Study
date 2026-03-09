resource "aws_wafv2_web_acl" "main" {
  name = "${var.name_prefix}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

	rule {
		name = "AWS-AWSManagedRulesCommonRuleSet"
		priority = 1
		
		override_action {
			count {}
		}

		statement {
			managed_rule_group_statement {
				name = "AWSManagedRulesCommonRuleSet"
				vendor_name = "AWS"
			}
		}
		# ルールのvisibility_config
		visibility_config {
			metric_name = "AWS-AWSManagedRulesCommonRuleSet"
			cloudwatch_metrics_enabled = true
			sampled_requests_enabled = true
		}
	}

	# WebACL全体のvisibility_config
	visibility_config {
		metric_name = "aws-waf-logs-${var.name_prefix}-web-acl"
		cloudwatch_metrics_enabled = true
		sampled_requests_enabled = true
	}
}

resource "aws_wafv2_web_acl_association" "main" {
	web_acl_arn = aws_wafv2_web_acl.main.arn
	resource_arn = var.web_acl_association_resource_arn
}
