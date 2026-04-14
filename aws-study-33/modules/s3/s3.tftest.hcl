variables {
  name_prefix = "example"
}

# パブリックアクセスブロック設定
run "main_public_access_block" {
  command = plan

  assert {
    condition = (
      aws_s3_bucket_public_access_block.main.block_public_acls &&
      aws_s3_bucket_public_access_block.main.block_public_policy &&
      aws_s3_bucket_public_access_block.main.ignore_public_acls &&
      aws_s3_bucket_public_access_block.main.restrict_public_buckets
    )
    error_message = "S3へのパブリックアクセスブロック設定が予期していたものと違います"
  }
}

run "main_ownership_controls" {
  command = plan

  assert {
    condition = length([
      for rule in aws_s3_bucket_ownership_controls.main.rule :
      rule
      if rule.object_ownership == "BucketOwnerEnforced"
    ]) > 0
    error_message = "バケットの所有権の設定が予期していたものと違います"
  }
}

run "main_versioning" {
  command = plan

  assert {
    condition = length([
      for config in aws_s3_bucket_versioning.main.versioning_configuration :
      config
      if config.status == "Enabled"
    ]) > 0
    error_message = "バケットのバージョニング設定が予期していたものと違います"
  }
}
