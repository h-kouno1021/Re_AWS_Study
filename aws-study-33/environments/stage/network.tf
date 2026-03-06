module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  my_env         = var.my_env
  pj_prefix      = var.pj_prefix
}
