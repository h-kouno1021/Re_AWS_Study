module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  name_prefix    = local.name_prefix
}

module "alb" {
  source = "../../modules/alb"

  name_prefix       = local.name_prefix
  public_subnets_id = values(module.vpc.public_subnet_ids)
  target_id         = aws_instance.ec2.id
  vpc_id            = module.vpc.vpc_id
}

module "waf" {
  source = "../../modules/waf"

  name_prefix                      = local.name_prefix
  web_acl_association_resource_arn = module.alb.lb_arn
}
