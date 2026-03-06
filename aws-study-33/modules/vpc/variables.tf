variable "my_env" {
  type = string
  description = "Deployment environment"
  validation {
    condition = contains(["stage","prod"], var.my_env)
    error_message = "my_env must be stage or prod."
  }
}

variable "pj_prefix" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}
