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
