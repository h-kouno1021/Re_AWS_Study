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
variable "key_name" {
  type        = string
  description = "Name of an existing EC2 KeyPair to SSH into the instance"
}
variable "subscribes_email_address" {
  type        = string
  description = "The email address to receive alarm notifications"
  sensitive   = true
}
variable "my_ip" {
  type = string
}

# RDS
variable "rds_instance_config" {
  type    = string
  default = "db.t4g.micro"
}
variable "rds_monitoring_role_name" {
  type        = string
  description = "This parameter allows a string of characters consisting of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: _+=,.@-."
  default     = "rds-monitoring-role"
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
