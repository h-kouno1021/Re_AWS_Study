locals {
  # リソース名の接頭辞
  name_prefix = "${var.pj_prefix}-terraform-${var.my_env}"
}

variable "my_env" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["stage", "prod"], var.my_env)
    error_message = "my_env must be stage or prod."
  }
}
variable "pj_prefix" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}

# EC2
variable "ec2_instance_config" {
  type    = string
  default = "t2.micro"
}
variable "my_ip" {
  type = string
}

# RDS
variable "rds_instance_config" {
  type    = string
  default = "db.t4g.micro"
}
variable "rds_multi_az" {
  type    = bool
  default = true
}
variable "rds_db_name" {
  type    = string
  default = "awsstudy"
}
variable "rds_db_username" {
  type      = string
  sensitive = true
}
variable "rds_db_password" {
  type      = string
  sensitive = true
}
