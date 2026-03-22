output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "cidr_block" {
  value = aws_vpc.main_vpc.cidr_block
}

output "public_subnet_ids" {
  value = {
    for az, subnet in local.subnets :
    az => aws_subnet.subnets[az].id
    if subnet.type == "public"
  }
}

output "private_subnet_ids" {
  value = {
    for az, subnet in local.subnets :
    az => aws_subnet.subnets[az].id
    if subnet.type == "private"
  }
}
