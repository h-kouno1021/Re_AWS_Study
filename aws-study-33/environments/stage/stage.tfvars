vpc_cidr_block = "10.0.0.0/16"
my_env         = "stage"

# EC2
ec2_instance_config = "t2.micro"

# RDS
rds_engine_version             = "8.4.7"
rds_instance_config            = "db.t4g.micro"
rds_multi_az                   = "false"
rds_monitoring_role_name       = "rds-monitoring-role"
rds_enable_deletion_protection = "false"
rds_db_name                    = "awsstudy"
