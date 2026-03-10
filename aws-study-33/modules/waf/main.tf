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

# ログの出力先の設定
resource "aws_cloudwatch_log_group" "waf" {
	# ロググループ名は"aws-waf-logs-"から始まる必要があります
	name = "aws-waf-logs-${var.name_prefix}-web-acl"

	deletion_protection_enabled = false
	skip_destroy = false

	tags = {
		"Name" = "aws-waf-logs-${var.name_prefix}-web-acl"
	}
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
	log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
	resource_arn = aws_wafv2_web_acl.main.arn
}

resource "aws_cloudwatch_log_resource_policy" "waf" {
	policy_name = "WAFToCWLogsPolicy"
	policy_document = data.aws_iam_policy_document.delivery_logs.json
}

# ポリシー設定
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "delivery_logs" {
	version = "2012-10-17"
	statement {
		effect = "Allow"
		
		principals {
			type = "Service"
			identifiers = ["delivery.logs.amazonaws.com"]
		}

		actions = [ 
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		 ]

		 resources = [
			"${aws_cloudwatch_log_group.waf.arn}:*",
		]
		# 指定のAWSアカウントからのリクエストのみ許可
		condition {
			test = "StringEquals"
			variable = "aws:SourceAccount"
			values = [
				data.aws_caller_identity.current.account_id,
			]
		}
		# 指定のAWSアカウントからのログのみ許可
		condition {
			test = "ArnLike"
			variable = "aws:SourceArn"
			values = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
		}
	}
}
