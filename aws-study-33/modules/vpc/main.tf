# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  
  tags = {
    Name = "${var.pj_prefix}-terraform-${var.my_env}-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.pj_prefix}-terraform-${var.my_env}-igw"
  }
}

resource "aws_route" "route_public" {
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.pubsub_route_table.id
}

# SubNet
locals {
  subnets = {
    "public-1a"  = { az = "ap-northeast-1a", cidr = "${cidrsubnet(var.vpc_cidr_block, 4, 0)}", type = "public" }
    "public-1c"  = { az = "ap-northeast-1c", cidr = "${cidrsubnet(var.vpc_cidr_block, 4, 1)}", type = "public" }
    "private-1a" = { az = "ap-northeast-1a", cidr = "${cidrsubnet(var.vpc_cidr_block, 4, 8)}", type = "private" }
    "private-1c" = { az = "ap-northeast-1c", cidr = "${cidrsubnet(var.vpc_cidr_block, 4, 9)}", type = "private" }
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id = aws_vpc.main_vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = each.value.type == "public"

  tags = {
    Name = "${var.pj_prefix}-terraform-${var.my_env}-subnet-${each.key}"
  }
}

# RouteTable
resource "aws_route_table" "pubsub_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.pj_prefix}-terraform-${var.my_env}-pubsub-routetable"
  }
}

resource "aws_route_table_association" "association_pubsub_route_table" {
  for_each = {
    for az, subnet in local.subnets :
    az => subnet
    if subnet.type == "public"
  }

  subnet_id = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.pubsub_route_table.id
}

resource "aws_route_table" "pvtsub_route_table" {
  for_each = {
    for az, subnet in local.subnets :
    az => subnet
    if subnet.type == "private"
  }

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.pj_prefix}-terraform-${var.my_env}-${each.key}-routetable"
  }
}

resource "aws_route_table_association" "association_pvtsub_route_table" {
  for_each = {
    for az, subnet in local.subnets :
    az => subnet
    if subnet.type == "private"
  }

  subnet_id = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.pvtsub_route_table[each.key].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for az, subnet in local.subnets :
    aws_route_table.pvtsub_route_table[az].id
    if subnet.type == "private"
  ]
}
