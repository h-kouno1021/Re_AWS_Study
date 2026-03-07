# RDSがAmazon CloudWatch Logsに拡張モニタリングメトリクスを送信することを許可するためのロール
data "aws_iam_policy" "monitoring_policy_rds" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role" "monitoring_rds" {
  name = "rds-monitoring-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_monitoring_policy_rds" {
  role       = aws_iam_role.monitoring_rds.name
  policy_arn = data.aws_iam_policy.monitoring_policy_rds.arn
}
