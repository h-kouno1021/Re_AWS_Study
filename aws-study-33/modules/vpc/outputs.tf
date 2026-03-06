output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  value = [
    for az, subnet in local.subnets :
    aws_subnet.subnets[az].id
    if subnet.type == "public"
  ]
}

output "private_subnet_ids" {
  value = [
    for az, subnet in local.subnets :
    aws_subnet.subnets[az].id
    if subnet.type == "private"
  ]
}
