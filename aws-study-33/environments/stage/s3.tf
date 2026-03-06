module "s3" {
  source = "../../modules/s3"

  my_env         = var.my_env
  pj_prefix      = var.pj_prefix
}
