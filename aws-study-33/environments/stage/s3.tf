module "s3" {
  source = "../../modules/s3"

  name_prefix = local.name_prefix
}
