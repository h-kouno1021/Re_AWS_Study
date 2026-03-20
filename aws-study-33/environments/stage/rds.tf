# AZのリストを取得
data "aws_availability_zones" "available" {}

# RDSインスタンス
resource "aws_db_instance" "main" {
  identifier                  = "${local.name_prefix}-rds"
  engine                      = "mysql"
  engine_version              = var.rds_engine_version
  instance_class              = var.rds_instance_config
  storage_type                = "gp2"
  allocated_storage           = "20"
  max_allocated_storage       = "1000"
  port                        = "3306"
  publicly_accessible         = false
  storage_encrypted           = true
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  deletion_protection         = var.rds_enable_deletion_protection

  multi_az               = var.rds_multi_az
  availability_zone      = data.aws_availability_zones.available.names[0]
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot             = false
  username                        = var.rds_db_username
  password                        = var.rds_db_password
  db_name                         = var.rds_db_name
  backup_retention_period         = 7
  monitoring_role_arn             = aws_iam_role.monitoring_rds.arn
  monitoring_interval             = 60
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = {
    Name = "${local.name_prefix}-rds"
  }
}

# DBサブネットグループ
resource "aws_db_subnet_group" "rds" {
  name       = "${local.name_prefix}-rds-db-subnet-group"
  subnet_ids = values(module.vpc.private_subnet_ids)

  tags = {
    Name = "${local.name_prefix}-rds-db-subnet-group"
  }
}

# セキュリティグループ

locals {
  # 接続を許可するEC2のセキュリティグループIDの値の条件分岐
  ec2_sg_id = (
    var.ec2_sg_id != null
      ? var.ec2_sg_id
      : aws_security_group.ec2_sg.id
  )
}
resource "aws_security_group" "rds" {
  vpc_id = module.vpc.vpc_id
  name   = "${local.name_prefix}-rds-sg"

  # 指定のEC2からのアクセスのみ許可
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [local.ec2_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}
