variables {
  name_prefix    = "example"
  vpc_cidr_block = "10.0.0.0/16"
}

# VPC CIDRブロックの検証
run "vpc_cidr_block" {
  command = plan

  assert {
    condition     = aws_vpc.main_vpc.cidr_block == "10.0.0.0/16"
    error_message = "vpc_cidr_blockの値が違います"
  }
}

# サブネットの数の検証
run "subnets" {
  command = plan

  assert {
    condition = length([
      for k in aws_subnet.subnets :
      k
      if k.map_public_ip_on_launch == true
    ]) == 2
    error_message = "パブリックサブネットの数が想定と違います"
  }

  assert {
    condition = length([
      for k in aws_subnet.subnets :
      k
      if k.map_public_ip_on_launch == false
    ]) == 2
    error_message = "プライベートサブネットの数が想定と違います"
  }
}
