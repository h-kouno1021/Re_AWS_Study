variable "name_prefix" {
  type        = string
  description = "Resourses name prefix"
}

# ターゲットのインスタンスID
variable "target_id" {
  type        = string
  description = "Target instance ID"
}

# LBに接続するサブネットIDのリスト
variable "public_subnets_id" {
  type        = list(string)
  description = "List of subnet IDs to attach to the LB."
}

# TGを作成するVPCのID
variable "vpc_id" {
  type        = string
  description = "Identifier of the VPC in which to create the target group."
}
